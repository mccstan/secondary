#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "skiplist.h"

int compare(const void *a, const void *b, void *ctx) { return strcmp(a, b); }

int main(void) {
  char *words[] = {"foo",  "bar",     "zap",    "pomo",
                   "pera", "arancio", "limone", NULL};
  char *vals[] = {"foo val",  "bar val",     "zap val",    "pomo val",
                  "pera val", "arancio val", "limone val", NULL};
  int j;

  skiplist *sl = skiplistCreate(compare, NULL);
  for (j = 0; words[j] != NULL; j++)
    printf("Insert %s: %p\n", words[j], skiplistInsert(sl, words[j], vals[j]));

  /* The following should fail. */
  printf("\nInsert %s again: %p\n\n", words[2],
         skiplistInsert(sl, words[2], vals[2]));

  skiplistIterator it = skiplistIterateRange(sl, "limone", NULL, 0, 0);
  skiplistNode *val;
  while (NULL != (val = skiplistIterator_Next(&it))) {
    printf("Iterator: %s\n", val->val);
  }
  skiplistNode *x;
  x = sl->header;
  x = x->level[0].forward;
  while (x) {
    printf("%s\n", x->obj);
    x = x->level[0].forward;
  }

  printf("Searching for 'hello': %p\n", skiplistFind(sl, "hello"));
  printf("Searching for 'pera': %p\n", skiplistFind(sl, "pera"));

  printf("Pop from head: %s\n", skiplistPopHead(sl));
  printf("Pop from head: %s\n", skiplistPopHead(sl));

  printf("Pop from tail: %s\n", skiplistPopTail(sl));
  printf("Pop from tail: %s\n", skiplistPopTail(sl));
  printf("Pop from tail: %s\n", skiplistPopTail(sl));
  printf("Pop from tail: %s\n", skiplistPopTail(sl));
  printf("Pop from tail: %s\n", skiplistPopTail(sl));
  printf("Pop from tail: %s\n", skiplistPopTail(sl));

  printf("Pop from head: %s\n", skiplistPopTail(sl));
}