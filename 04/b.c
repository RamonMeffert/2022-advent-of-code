#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

bool has_overlap(char line[]) {
    char delim[] = ",-";
    char* tok;
    int r[4];
    int i = 0;
    for(tok = strtok(line, delim); tok; tok = strtok(NULL, delim)) {
        r[i++] = atoi(tok);
    }
    if ((r[0] <= r[2] && r[2] <= r[1]) || (r[2] <= r[0] && r[0] <= r[3])) {
        return true;
    }
    return false;
}

int main(void) {
    FILE *input;
    input = fopen("input", "r");

    if (input == NULL) {
        return 1;
    }
    
    int count = 0;
    char line[16]; // no line seems to be longer than 16 characters.
    while (fgets(line, 16, input)) {
        line[strcspn(line, "\n")] = 0; // remove '\n'
        if (has_overlap(line)) {
            count++;
        }
    }
    printf("%d assignment pairs overlap.\n", count);

    fclose(input);
    return 0;
}
