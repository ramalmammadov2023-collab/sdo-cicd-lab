#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* Convert text to a number. Returns 1 if OK, 0 if the text is not a number. */
static int parse(const char *text, double *out) {
    char *end;
    *out = strtod(text, &end);
    return end != text && *end == '\0';
}

int main(int argc, char *argv[]) {
    double base, exponent;

    if (argc == 3) {
        if (!parse(argv[1], &base) || !parse(argv[2], &exponent)) {
            fprintf(stderr, "Error: base and exponent must be numbers.\n");
            return 1;
        }
    } else {
        printf("Enter the base: ");
        fflush(stdout);
        if (scanf("%lf", &base) != 1) {
            fprintf(stderr, "Invalid number.\n");
            return 1;
        }
        printf("Enter the exponent: ");
        fflush(stdout);
        if (scanf("%lf", &exponent) != 1) {
            fprintf(stderr, "Invalid number.\n");
            return 1;
        }
    }

    /* A negative base with a fractional exponent has no real result */
    if (base < 0 && exponent != floor(exponent)) {
        fprintf(stderr, "Error: negative base needs a whole-number exponent.\n");
        return 2;
    }

    printf("%g ^ %g = %g\n", base, exponent, pow(base, exponent));
    return 0;
}
