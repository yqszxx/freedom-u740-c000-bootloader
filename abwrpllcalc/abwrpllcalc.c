#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <locale.h>

#define MIN(X, Y)    (((X) < (Y)) ? (X) : (Y))
#define DIV_UP(X, Y) (((X) + (Y) - 1) / (Y))

#define MAX_INPUT_FREQ       600000000ULL
#define MIN_POST_DIVR_FREQ     7000000ULL
#define MAX_POST_DIVR_FREQ   200000000ULL
#define MAX_DIVR_DIVISOR            64ULL
#define MIN_VCO_FREQ        2400000000ULL
#define MAX_VCO_FREQ        4800000000ULL
#define MAX_DIVQ_DIVISOR            64ULL    // divq = 6
#define ROUND_SHIFT 20  // number of bits to shift to avoid precision loss in the rounding algorithm

union reg_t {
    struct bitfields {
        uint32_t r : 6;
        uint32_t f : 9;
        uint32_t q : 3;
        uint32_t range : 3;
        uint32_t res1 : 3;
        uint32_t bypass : 1;
        uint32_t fsebypass : 1;
        uint32_t res2 : 5;
        uint32_t lock : 1;
    } bf;
    uint32_t bits;
} reg;

/**
 * __fls - find last (most-significant) set bit in a long word
 * @word: the word to search
 *
 * Undefined if no set bit exists, so code should check against 0 first.
 */
static unsigned int ilog2(uint64_t word)
{
    int num = 64 - 1;

    if (!(word & (~0ul << 32))) {
        num -= 32;
        word <<= 32;
    }
    if (!(word & (~0ul << 48))) {
        num -= 16;
        word <<= 16;
    }
    if (!(word & (~0ul << 56))) {
        num -= 8;
        word <<= 8;
    }
    if (!(word & (~0ul << 60))) {
        num -= 4;
        word <<= 4;
    }
    if (!(word & (~0ul << 62))) {
        num -= 2;
        word <<= 2;
    }
    if (!(word & (~0ul << 63)))
        num -= 1;
    return num;
}

int main(int argc, char** argv) {
    reg.bits = 0;

    setlocale(LC_NUMERIC, "");

    if ((argc != 4 && argc != 6) || argv[1][0] < 'a' || argv[1][0] > 'c') {
        printf("ERROR: usage %s a <input freq MHz> <output freq kHz>\n", argv[0]);
        printf("             %s b <input freq MHz> <reg hex w/o 0x>\n", argv[0]);
        printf("             %s c <input freq MHz> <R> <F> <Q>\n", argv[0]);
        return 1;
    }

    if (argv[1][0] == 'c') { // RFQ -> ofreq
        uint64_t ifreq = strtoull(argv[2], NULL, 10) * 1000000ULL;
        uint64_t divr = strtoull(argv[3], NULL, 10);
        uint64_t divf = strtoull(argv[4], NULL, 10);
        uint64_t divq = strtoull(argv[5], NULL, 10);

        printf("Input frequency: %'15lu Hz\n", ifreq);
        printf("              R: %15lu\n", divr);
        printf("              F: %15lu\n", divf);
        printf("              Q: %15lu\n", divq);

        printf("\n\n==== result ====\n");
        uint64_t actFreq = (ifreq >> (divq - 1)) / (divr + 1) * (divf + 1);
        printf("VCO:\t%'15lu Hz\n", ifreq * 2 / (divr + 1) * (divf + 1));
        printf("Output:\t%'15lu Hz\n", actFreq);

        return 0;
    }

    uint64_t ifreq = strtoull(argv[2], NULL, 10) * 1000000ULL;
    uint64_t ofreq = strtoull(argv[3], NULL, 10) * 1000ULL;

    printf("Input frequency:  %'15lu Hz\n", ifreq);
    printf("Output frequency: %'15lu Hz\n", ofreq);

    if (ifreq > MAX_INPUT_FREQ || ifreq < MIN_POST_DIVR_FREQ) {
        printf("ERROR: Input frequency out of range (%'lu, %'lu).\n", MIN_POST_DIVR_FREQ, MAX_INPUT_FREQ);
        return 1;
    }

    uint8_t maxRForInput = ifreq / MIN_POST_DIVR_FREQ;
    uint8_t maxR = MIN(MAX_DIVR_DIVISOR, maxRForInput);
    uint8_t initR = DIV_UP(ifreq, MAX_POST_DIVR_FREQ);

    if (ifreq == ofreq) {
        reg.bf.bypass = 1;
    }

    uint64_t divq = 0;
    uint64_t targetVcoFreq = 0ULL;
    uint64_t s = MAX_VCO_FREQ / ofreq;
    if (s <= 1) {
        divq = 1;
        targetVcoFreq = MAX_VCO_FREQ;
    } else if (s > MAX_DIVQ_DIVISOR) {
        divq = ilog2(MAX_DIVQ_DIVISOR);
        targetVcoFreq = MIN_VCO_FREQ;
    } else {
        divq = ilog2(s);
        targetVcoFreq = ofreq << divq;
    }

    if (divq == 0) {
        printf("ERROR: Bad Q.\n");
        return 1;
    }

    // Precalculate the pre-Q divider target ratio
    uint64_t ratio = (targetVcoFreq << ROUND_SHIFT) / ifreq;

    uint64_t fb = 2ULL;
    uint64_t bestR = 0ULL;
    uint64_t bestF = 0ULL;
    uint64_t bestDelta = MAX_VCO_FREQ;

    for (uint64_t r = initR; r <= maxR; ++r) {
        uint64_t predivFreq = ratio * r;
        uint64_t f = (predivFreq + (1 << ROUND_SHIFT)) >> ROUND_SHIFT;
        f /= fb;

        uint64_t postdivFreq = ifreq / r;
        uint64_t vcoPre = fb * postdivFreq;
        uint64_t vco = vcoPre * f;

        if (vco > targetVcoFreq) {
            --f;
            vco = vcoPre * f;
        } else if (vco < MIN_VCO_FREQ) {
            ++f;
            vco = vcoPre * f;
        }

        uint64_t delta = 0ULL;
        if (ofreq > vco) {
            delta = ofreq - vco;
        } else {
            delta = vco - ofreq;
        }

        if (delta < bestDelta) {
            bestDelta = delta;
            bestR = r;
            bestF = f;
        }
    }

    uint64_t divr = bestR - 1;
    uint64_t divf = bestF - 1;

    uint64_t postdivrFreq = ifreq / bestR;

    if (postdivrFreq < MIN_POST_DIVR_FREQ || postdivrFreq > MAX_POST_DIVR_FREQ) {
        printf("ERROR: Post-divider reference freq out of range: %'lu\n", postdivrFreq);
        return 1;
    }

    uint64_t range = 0;

    switch (postdivrFreq) {
        case 0 ... 10999999:
            range = 1;
            break;
        case 11000000 ... 17999999:
            range = 2;
            break;
        case 18000000 ... 29999999:
            range = 3;
            break;
        case 30000000 ... 49999999:
            range = 4;
            break;
        case 50000000 ... 79999999:
            range = 5;
            break;
        case 80000000 ... 129999999:
            range = 6;
            break;
        default:
            range = 7;
            break;
    }

    reg.bf.r = divr;
    reg.bf.f = divf;
    reg.bf.q = divq;
    reg.bf.range = range;
    reg.bf.fsebypass = 1;


    printf("\n\n==== result ====\n");
    printf("R:     %3lu\n", divr);
    printf("F:     %3lu\n", divf);
    printf("Q:     %3lu\n", divq);
    printf("Range: %3lu\n\n", range);

    printf("Requested:\t%'15lu Hz\n", ofreq);
    uint64_t actFreq = (ifreq >> (divq - 1)) / (divr + 1) * (divf + 1);
    printf("VCO:\t\t%'15lu Hz\n", ifreq * 2 / (divr + 1) * (divf + 1));
    printf("Actual:\t\t%'15lu Hz\n", actFreq);
    uint64_t delt = (actFreq > ofreq) ? (actFreq - ofreq) : (ofreq - actFreq);
    printf("Delta:\t\t%'15lu Hz (%lf %%)\n\n", delt, ((double)delt) / ofreq * 100);

    printf("Reg: 0x%08X\n", reg.bits);
    return 0;
}

