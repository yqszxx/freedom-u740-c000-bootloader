/* Copyright (c) 2018 SiFive, Inc */
/* SPDX-License-Identifier: Apache-2.0 */
/* SPDX-License-Identifier: GPL-2.0-or-later */
/* See the file LICENSE for further information */

#ifndef _SIFIVE_UX00PRCI_H
#define _SIFIVE_UX00PRCI_H

/* Register offsets */

#define UX00PRCI_HFROSCCFG          (0x0000)
#define UX00PRCI_COREPLLCFG         (0x0004)
#define UX00PRCI_COREPLLOUT         (0x0008)
#define UX00PRCI_DDRPLLCFG          (0x000C)
#define UX00PRCI_DDRPLLOUT          (0x0010)
#define UX00PRCI_PCIEAUXCFG         (0x0014)
#define UX00PRCI_GEMGXLPLLCFG       (0x001C)
#define UX00PRCI_GEMGXLPLLOUT       (0x0020)
#define UX00PRCI_CORECLKSELREG      (0x0024)
#define UX00PRCI_DEVICESRESETREG    (0x0028)
#define UX00PRCI_CLKMUXSTATUSREG    (0x002C)
#define UX00PRCI_HFPCLKPLLCFG       (0x0050)
#define UX00PRCI_HFPCLKPLLOUT       (0x0054)
#define UX00PRCI_HFPCLKSELREG       (0x0058)
#define UX00PRCI_HFPCLKDIVREG       (0x005C)
#define UX00PRCI_PROCMONCFG         (0x00F0)

/* Fields */
#define XOSC_EN(x)     (((x) & 0x1) << 30)
#define XOSC_RDY(x)    (((x) & 0x1) << 31)

#define PLL_R(x)       (((x) & 0x3F)  << 0)
#define PLL_F(x)       (((x) & 0x1FF) << 6)
#define PLL_Q(x)       (((x) & 0x7)  << 15)
#define PLL_RANGE(x)   (((x) & 0x7)  << 18)
#define PLL_BYPASS(x)  (((x) & 0x1)  << 24)
#define PLL_FSE(x)     (((x) & 0x1)  << 25)
#define PLL_LOCK(x)    (((x) & 0x1)  << 31)

#define PLLOUT_DIV(x)      (((x) & 0x7F) << 0)
#define PLLOUT_DIV_BY_1(x) (((x) & 0x1)  << 8)
#define PLLOUT_CLK_EN(x)   (((x) & 0x1)  << 31)

#define PLL_R_default 0x1
#define PLL_F_default 0x1F
#define PLL_Q_default 0x3
#define PLL_RANGE_default 0x0
#define PLL_BYPASS_default 0x1
#define PLL_FSE_default 0x1

#define PLLOUT_DIV_default  0x0
#define PLLOUT_DIV_BY_1_default 0x0
#define PLLOUT_CLK_EN_default 0x0

#define PLL_CORECLKSEL_HFXIN   0x1
#define PLL_CORECLKSEL_COREPLL 0x0


#define DEVICESRESET_DDR_CTRL_RST_N(x)          (((x) & 0x1)  << 0)
#define DEVICESRESET_DDR_AXI_RST_N(x)           (((x) & 0x1)  << 1)
#define DEVICESRESET_DDR_AHB_RST_N(x)           (((x) & 0x1)  << 2)
#define DEVICESRESET_DDR_PHY_RST_N(x)           (((x) & 0x1)  << 3)
#define DEVICESRESET_PCIEAUX_RST_N(x)           (((x) & 0x1)  << 4)
#define DEVICESRESET_GEMGXL_RST_N(x)            (((x) & 0x1)  << 5)

#define CLKMUX_STATUS_CORECLKPLLSEL          (0x1 << 0)
#define CLKMUX_STATUS_TLCLKSEL               (0x1 << 1)
#define CLKMUX_STATUS_RTCXSEL                (0x1 << 2)
#define CLKMUX_STATUS_DDRCTRLCLKSEL          (0x1 << 3)
#define CLKMUX_STATUS_DDRPHYCLKSEL           (0x1 << 4)
#define CLKMUX_STATUS_GEMGXLCLKSEL           (0x1 << 6)


#define PCIEAUXCFG_CLKEN(x)    (((x) & 0x1)  << 0)

#ifndef __ASSEMBLER__

#include <stdint.h>

static inline int ux00prci_select_corepll (
  volatile uint32_t *coreclkselreg,
  volatile uint32_t *corepllcfg,
  uint32_t pllconfigval)
{
  
  (*corepllcfg) = pllconfigval;
  
  // Wait for lock
  while (((*corepllcfg) & (PLL_LOCK(1))) == 0) ;
  
  // Set CORECLKSELREG to select COREPLL
  (*coreclkselreg) = PLL_CORECLKSEL_COREPLL;
  
  return 0;
  
}

static inline int ux00prci_select_corepll_1200MHz(
  volatile uint32_t *coreclkselreg,
  volatile uint32_t *corepllcfg)
{
  //
  // CORE pll init
  // Set corepll 26MHz -> 1.2GHz
  //

  uint32_t core1200MHz =
    (PLL_R(2)) |
    (PLL_F(275)) |  /*4784MHz VCO*/
    (PLL_Q(2)) |   /* /4 Output divider */
    (PLL_RANGE(0x1)) |
    (PLL_BYPASS(0)) |
    (PLL_FSE(1));

  return ux00prci_select_corepll(coreclkselreg, corepllcfg, core1200MHz);
  
}

#endif

#endif // _SIFIVE_UX00PRCI_H
