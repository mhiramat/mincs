/* leash - least capability/isolation shell - leash your process! */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/mount.h>
#include <getopt.h>
#include <errno.h>

/* According to man pivot_root(2), we need a wrapper for this syscall */
static inline int pivot_root(const char *new_root, const char *put_old)
{
	return syscall(SYS_pivot_root, new_root, put_old);
}

static void usage(void)
{
	printf("Usage: leash <new_root> <command>\n");
}

#define MOUNT_TABLE "/proc/mounts"
static char **read_mount_points(size_t *nr_entry)
{
	FILE *fp;
	char *buf, *ptr, *end;
	size_t n, i = 0, max = 64;
	char **ret, **new;

	ret = calloc(max, sizeof(char *));
	fp = fopen(MOUNT_TABLE, "r");
	if (fp == NULL)
		return NULL;

	while (!feof(fp)) {
		buf = NULL; n = 0;
		if (getline(&buf, &n, fp) < 0)
			break;
		ptr = strchr(buf, ' ');
		if (!ptr)
			break;
		end = ++ptr;
		do {
			end = strchr(end, ' ');
			if (!end)
				goto out;
		} while (*(end - 1) == '\\' && end++);
		*end = '\0';
		ret[i++] = strdup(ptr);
		free(buf);
		/* Expand array if needed */
		if (i == max) {
			new = calloc(max * 2, sizeof(char *));
			if (!new)
				break;
			memcpy(new, ret, max);
			max *= 2;
			free(ret);
			ret = new;
		}
	}
out:

	if (nr_entry)
		*nr_entry = i;
	fclose(fp);
	return ret;
}

static int rev_strcmp(const void *a, const void *b)
{
	return strcmp(*(const char **)b, *(const char **)a);
}

static int umount_recursive(const char *topdir)
{
	char **mount_points;
	size_t i, nr = 0, n = strlen(topdir);
	int ret = 0;

	mount_points = read_mount_points(&nr);
	if (!mount_points)
		return -EINVAL;
	/* Reverse sort */
	qsort(mount_points, nr, sizeof(char *), rev_strcmp);
	for (i = 0; i < nr; i++) {
		if (strncmp(mount_points[i] + 1, topdir, n))
			continue;
		ret = umount(mount_points[i]);
		if (ret < 0) {
			fprintf(stderr, "Failed to umount %s: %s\n",
					mount_points[i], strerror(errno));
		}
	}

	for (i = 0; i < nr; i++)
		free(mount_points[i]);
	free(mount_points);

	return ret;
}

static int wash_environ(const char *pat, char *envp[])
{
	return 0;
}

int main(int argc, char *argv[], char *envp[])
{
	char *new_root = argv[1];
	char old_holder[] = ".orig-XXXXXX";

	if (argc < 2) {
		usage();
		return -1;
	}

	if (chdir(new_root) < 0) {
		perror("chdir");
		return -1;
	}

	/* Make a temporary directory */
	if (!mkdtemp(old_holder)) {
		perror("mkdtemp");
		return -1;
	}

	if (pivot_root(".", old_holder) < 0) {
		fprintf(stderr, "pivot_root(%s,%s)\n", new_root, old_holder);
		perror("pivot_root");
		return -1;
	}

	if (chroot(".") < 0) {
		perror("chroot");
		return -1;
	}

	if (chdir("/") < 0) {
		perror("chdir");
		return -1;
	}

	if (umount_recursive(old_holder) < 0)
		goto failback;

	if (rmdir(old_holder) < 0) {
		perror("rmdir");
		goto failback;
	}

	execve(argv[2], argv + 2, envp);
	perror("execve");
failback:
	execl("/bin/bash", "", (char *)0);
	return 0;
}
