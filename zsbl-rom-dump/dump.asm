0000000000010000 <.data>:
# $mtvec = 0x10108
   10000:       00000297                auipc   t0,0x0
   10004:       10828293                addi    t0,t0,264 # 0x10108
   10008:       30529073                csrw    mtvec,t0

# $mie = 8
   1000c:       4921                    li      s2,8
   1000e:       30491073                csrw    mie,s2

# if ($mhartid == 0)
   10012:       4481                    li      s1,0
   10014:       f1402973                csrr    s2,mhartid
   10018:       09249863                bne     s1,s2, 42f // 0x100a8
# {
#   *(uint32_t*)0x0308_0000 = 1  // PDMA_C0_CTRL.claim = 1
   1001c:       030802b7                lui     t0,0x3080
   10020:       4305                    li      t1,1
   10022:       0062a023                sw      t1,0(t0) # 0x0308_0000
#   *(uint32_t*)0x0308_0008 = 0x001e_0000  // PDMA_C0_NEXTBYTE = 1966080 = 1920K
   10026:       001e0337                lui     t1,0x1e0
   1002a:       0062b423                sd      t1,8(t0)
#   *(uint32_t*)0x0308_0010 = 0x0800_0000  // PDMA_C0_NEXTDST = 0x0800_0000 (L2 Cache Controller)
   1002e:       08000337                lui     t1,0x8000
   10032:       0062b823                sd      t1,16(t0)
#   *(uint32_t*)0x0308_0010 = 0x0900_0000  // PDMA_C0_NEXTSRC = 0x0900_0000 (ROM)
   10036:       09000337                lui     t1,0x9000
   1003a:       0062bc23                sd      t1,24(t0)
#   *(uint32_t*)0x0308_0004 = 0xFF00_0000  // PDMA_C0_NEXTCFG.wsize = 2^15, rsize = 2^15
   1003e:       0ff0031b                addiw   t1,zero,255
   10042:       01831313                slli    t1,t1,0x18
   10046:       0062a223                sw      t1,4(t0)
#   *(uint32_t*)0x0308_0000 = 0x0000_0003  // PDMA_C0_CTRL.claim = 1, run = 1
   1004a:       430d                    li      t1,3
   1004c:       0062a023                sw      t1,0(t0)
#   while (*(uint32_t*)0x0308_0000 & 2 != 0) {}  // while PDMA_C0_CTRL.run == 1
   10050:       0002a303                lw      t1,0(t0)
   10054:       00237313                andi    t1,t1,2
   10058:       fe031ce3                bnez    t1,0x10050
#   *(uint32_t*)0x0308_0000 = 0x0000_0000  // PDMA_C0_CTRL = 0
   1005c:       0002a023                sw      zero,0(t0)
#   ????
   10060:       00003297                auipc   t0,0x3
   10064:       76028293                addi    t0,t0,1888 # 0x137c0
   10068:       080f0317                auipc   t1,0x80f0
   1006c:       f9830313                addi    t1,t1,-104 # 0x8100000
   10070:       02628063                beq     t0,t1,0x10090
#
   10074:       00003397                auipc   t2,0x3
   10078:       71438393                addi    t2,t2,1812 # 0x13788
   1007c:       00737a63                bgeu    t1,t2,0x10090
   10080:       0002be03                ld      t3,0(t0)
   10084:       01c33023                sd      t3,0(t1)
   10088:       02a1                    addi    t0,t0,8
   1008a:       0321                    addi    t1,t1,8
   1008c:       fe736ae3                bltu    t1,t2,0x10080
   10090:       020004b7                lui     s1,0x2000
   10094:       4905                    li      s2,1
   10096:       0124a023                sw      s2,0(s1) # 0x2000000
   1009a:       0491                    addi    s1,s1,4
   1009c:       02000937                lui     s2,0x2000
   100a0:       0809091b                addiw   s2,s2,128
   100a4:       ff24c8e3                blt     s1,s2,0x10094

42:
# } else {
#   WFI;
# }
   100a8:       10500073                wfi

   100ac:       34402973                csrr    s2,mip
   100b0:       00897913                andi    s2,s2,8
   100b4:       fe090ae3                beqz    s2,0x100a8
   100b8:       020004b7                lui     s1,0x2000
   100bc:       f1402973                csrr    s2,mhartid
   100c0:       090a                    slli    s2,s2,0x2
   100c2:       9926                    add     s2,s2,s1
   100c4:       00092023                sw      zero,0(s2) # 0x2000000
   100c8:       0004a903                lw      s2,0(s1) # 0x2000000
   100cc:       fe091ee3                bnez    s2,0x100c8
   100d0:       0491                    addi    s1,s1,4
   100d2:       02000937                lui     s2,0x2000
   100d6:       0809091b                addiw   s2,s2,128
   100da:       ff24c7e3                blt     s1,s2,0x100c8
   100de:       f14022f3                csrr    t0,mhartid
   100e2:       02b2                    slli    t0,t0,0xc
   100e4:       081d0117                auipc   sp,0x81d0
   100e8:       f1c10113                addi    sp,sp,-228 # 0x81e0000
   100ec:       40510133                sub     sp,sp,t0
   100f0:       086000ef                jal     ra,0x10176     // yq: call main
   100f4:       080002b7                lui     t0,0x8000
   100f8:       f1402573                csrr    a0,mhartid
   100fc:       00001597                auipc   a1,0x1
   10100:       d8458593                addi    a1,a1,-636 # 0x10e80    // yq: _dtb
   10104:       8282                    jr      t0
   10106:       0001                    nop
   10108:       038000ef                jal     ra,0x10140     // yq: handle_trap
        ...
   // ALIGN(64);
   // handle_trap
   10140:       34202573                csrr    a0,mcause
   10144:       4585                    li      a1,1
   10146:       5400006f                j       0x10686  // ux00boot_fail

   // void init_uart(unsigned int peripheral_input_khz)
   1014a:       1502                    slli    a0,a0,0x20
   1014c:       3e800793                li      a5,1000
   10150:       9101                    srli    a0,a0,0x20
   10152:       02f50533                mul     a0,a0,a5
   10156:       67f1                    lui     a5,0x1c
   10158:       1ff78693                addi    a3,a5,511 # 0x1c1ff
   1015c:       20078793                addi    a5,a5,512
   10160:       4701                    li      a4,0
   10162:       9536                    add     a0,a0,a3
   10164:       02f55533                divu    a0,a0,a5
   10168:       c119                    beqz    a0,0x1016e
   1016a:       fff5071b                addiw   a4,a0,-1
   1016e:       100107b7                lui     a5,0x10010
   10172:       cf98                    sw      a4,24(a5)
   10174:       8082                    ret

   // main
   10176:       1141                    addi    sp,sp,-16
   10178:       e406                    sd      ra,8(sp)
   1017a:       f14027f3                csrr    a5,mhartid
   1017e:       e38d                    bnez    a5,0x101a0
   10180:       100107b7                lui     a5,0x10010
   10184:       0e100713                li      a4,225
   10188:       6619                    lui     a2,0x6
   1018a:       cf98                    sw      a4,24(a5)
   1018c:       59060613                addi    a2,a2,1424 # 0x6590
   10190:       00003597                auipc   a1,0x3
   10194:       5d858593                addi    a1,a1,1496 # 0x13768
   10198:       08000537                lui     a0,0x8000
   1019c:       568000ef                jal     ra,0x10704     // yq: ux00boot_load_gpt_partition

   101a0:       080f0617                auipc   a2,0x80f0
   101a4:       e6060613                addi    a2,a2,-416 # 0x8100000 barrier
   101a8:       0ff0000f                fence
   101ac:       4a1c                    lw      a5,16(a2)
   101ae:       4505                    li      a0,1
   101b0:       0ff0000f                fence
   101b4:       2781                    sext.w  a5,a5
   101b6:       00279713                slli    a4,a5,0x2
   101ba:       00e606b3                add     a3,a2,a4
   101be:       0f50000f                fence   iorw,ow
   101c2:       04a6a5af                amoadd.w.aq     a1,a0,(a3)
   101c6:       0721                    addi    a4,a4,8
   101c8:       2581                    sext.w  a1,a1

   101ca:       4811                    li      a6,4
   101cc:       9732                    add     a4,a4,a2
   101ce:       03058b63                beq     a1,a6,0x10204

   101d2:       0ff0000f                fence
   101d6:       431c                    lw      a5,0(a4)
   101d8:       0ff0000f                fence
   101dc:       2781                    sext.w  a5,a5
   101de:       dbf5                    beqz    a5,0x101d2

   101e0:       567d                    li      a2,-1
   101e2:       0f50000f                fence   iorw,ow
   101e6:       04c6a7af                amoadd.w.aq     a5,a2,(a3)
   101ea:       2781                    sext.w  a5,a5
   101ec:       4685                    li      a3,1
   101ee:       00d78663                beq     a5,a3,0x101fa

   101f2:       60a2                    ld      ra,8(sp)
   101f4:       4501                    li      a0,0
   101f6:       0141                    addi    sp,sp,16
   101f8:       8082                    ret

   101fa:       0f50000f                fence   iorw,ow
   101fe:       0c07202f                amoswap.w.aq    zero,zero,(a4)
   10202:       bfc5                    j       0x101f2

   10204:       40f507bb                subw    a5,a0,a5
   10208:       0641                    addi    a2,a2,16
   1020a:       0f50000f                fence   iorw,ow
   1020e:       0cf6202f                amoswap.w.aq    zero,a5,(a2)

   10212:       57fd                    li      a5,-1
   10214:       0f50000f                fence   iorw,ow
   10218:       04f6a02f                amoadd.w.aq     zero,a5,(a3)
   
   1021c:       0f50000f                fence   iorw,ow
   10220:       0ca7202f                amoswap.w.aq    zero,a0,(a4)
   10224:       b7f9                    j       0x101f2


// spi_min_clk_divisor
   10226:       0015959b                slliw   a1,a1,0x1
   1022a:       357d                    addiw   a0,a0,-1
   1022c:       9d2d                    addw    a0,a0,a1
   1022e:       02b5553b                divuw   a0,a0,a1

   10232:       c111                    beqz    a0,0x10236
   10234:       357d                    addiw   a0,a0,-1
   10236:       8082                    ret


// spi_tx
   10238:       04850793                addi    a5,a0,72 # 0x8000048
   1023c:       40b7a7af                amoor.w a5,a1,(a5)
   10240:       02079713                slli    a4,a5,0x20
   10244:       fe074ae3                bltz    a4,0x10238
   10248:       8082                    ret


// spi_rx
   1024a:       457c                    lw      a5,76(a0)
   1024c:       2781                    sext.w  a5,a5
   1024e:       fe07cee3                bltz    a5,0x1024a
   10252:       0ff7f513                andi    a0,a5,255
   10256:       8082                    ret


// spi_txrx
   10258:       04850793                addi    a5,a0,72
   1025c:       40b7a7af                amoor.w a5,a1,(a5)
   10260:       02079713                slli    a4,a5,0x20
   10264:       fe074ae3                bltz    a4,0x10258
   10268:       457c                    lw      a5,76(a0)
   1026a:       2781                    sext.w  a5,a5
   1026c:       fe07cee3                bltz    a5,0x10268
   10270:       0ff7f513                andi    a0,a5,255
   10274:       8082                    ret


// spi_copy
1 spictrl->csmode.mode = SPI_CSMODE_AUTO;
11 10276:       4d18                    lw      a4,24(a0)
   10278:       87aa                    mv      a5,a0
12 1027a:       9b71                    andi    a4,a4,-4
13 1027c:       00276713                ori     a4,a4,2
14 10280:       cd18                    sw      a4,24(a0)
   10282:       470d                    li      a4,3
   10284:       04878513                addi    a0,a5,72 # 0x10010048
   10288:       40e5252f                amoor.w a0,a4,(a0)
   1028c:       02051813                slli    a6,a0,0x20
   10290:       fe084ae3                bltz    a6,0x10284
   10294:       47f8                    lw      a4,76(a5)
   10296:       fe074fe3                bltz    a4,0x10294
   1029a:       0106571b                srliw   a4,a2,0x10
   1029e:       0ff77713                andi    a4,a4,255
   102a2:       04878513                addi    a0,a5,72
   102a6:       40e5252f                amoor.w a0,a4,(a0)
   102aa:       02051813                slli    a6,a0,0x20
   102ae:       fe084ae3                bltz    a6,0x102a2
   102b2:       47f8                    lw      a4,76(a5)
   102b4:       fe074fe3                bltz    a4,0x102b2
   102b8:       0086571b                srliw   a4,a2,0x8
   102bc:       0ff77713                andi    a4,a4,255
   102c0:       04878513                addi    a0,a5,72
   102c4:       40e5252f                amoor.w a0,a4,(a0)
   102c8:       02051813                slli    a6,a0,0x20
   102cc:       fe084ae3                bltz    a6,0x102c0
   102d0:       47f8                    lw      a4,76(a5)
   102d2:       fe074fe3                bltz    a4,0x102d0
   102d6:       0ff67613                andi    a2,a2,255
   102da:       04878713                addi    a4,a5,72
   102de:       40c7272f                amoor.w a4,a2,(a4)
   102e2:       02071513                slli    a0,a4,0x20
   102e6:       fe054ae3                bltz    a0,0x102da
   102ea:       47f8                    lw      a4,76(a5)
   102ec:       fe074fe3                bltz    a4,0x102ea
   102f0:       ca8d                    beqz    a3,0x10322
   102f2:       fff6861b                addiw   a2,a3,-1
   102f6:       1602                    slli    a2,a2,0x20
   102f8:       9201                    srli    a2,a2,0x20
   102fa:       0605                    addi    a2,a2,1
   102fc:       962e                    add     a2,a2,a1
   102fe:       4681                    li      a3,0
   10300:       04878713                addi    a4,a5,72
   10304:       40d7272f                amoor.w a4,a3,(a4)
   10308:       02071513                slli    a0,a4,0x20
   1030c:       fe054ae3                bltz    a0,0x10300
   10310:       47f8                    lw      a4,76(a5)
   10312:       2701                    sext.w  a4,a4
   10314:       fe074ee3                bltz    a4,0x10310
   10318:       00e58023                sb      a4,0(a1)
   1031c:       0585                    addi    a1,a1,1
   1031e:       feb611e3                bne     a2,a1,0x10300
   10322:       4f98                    lw      a4,24(a5)
   10324:       4501                    li      a0,0
   10326:       9b71                    andi    a4,a4,-4
   10328:       cf98                    sw      a4,24(a5)
   1032a:       8082                    ret


// uart_putc
   1032c:       40b527af                amoor.w a5,a1,(a0)
   10330:       02079713                slli    a4,a5,0x20
   10334:       fe074ce3                bltz    a4,0x1032c
   10338:       8082                    ret


// uart_getc
   1033a:       415c                    lw      a5,4(a0)
   1033c:       2781                    sext.w  a5,a5
   1033e:       fe07cee3                bltz    a5,0x1033a
   10342:       0ff7f513                andi    a0,a5,255
   10346:       8082                    ret


// uart_puts
   10348:       0005c783                lbu     a5,0(a1)
   1034c:       cb99                    beqz    a5,0x10362
   1034e:       0585                    addi    a1,a1,1
   10350:       40f5272f                amoor.w a4,a5,(a0)
   10354:       02071693                slli    a3,a4,0x20
   10358:       fe06cce3                bltz    a3,0x10350
   1035c:       0005c783                lbu     a5,0(a1)
   10360:       f7fd                    bnez    a5,0x1034e
   10362:       8082                    ret


// uart_put_hex
   10364:       46f1                    li      a3,28
   10366:       4825                    li      a6,9
   10368:       5671                    li      a2,-4
   1036a:       00d5d73b                srlw    a4,a1,a3
   1036e:       8b3d                    andi    a4,a4,15
   10370:       05770793                addi    a5,a4,87
   10374:       00e86463                bltu    a6,a4,0x1037c
   10378:       03070793                addi    a5,a4,48
   1037c:       40f5272f                amoor.w a4,a5,(a0)
   10380:       02071893                slli    a7,a4,0x20
   10384:       fe08cce3                bltz    a7,0x1037c
   10388:       36f1                    addiw   a3,a3,-4
   1038a:       fec690e3                bne     a3,a2,0x1036a
   1038e:       8082                    ret


// uart_put_hex64
   10390:       4205d893                srai    a7,a1,0x20
   10394:       46f1                    li      a3,28
   10396:       4825                    li      a6,9
   10398:       5671                    li      a2,-4
   1039a:       00d8d73b                srlw    a4,a7,a3
   1039e:       8b3d                    andi    a4,a4,15
   103a0:       05770793                addi    a5,a4,87
   103a4:       00e86463                bltu    a6,a4,0x103ac
   103a8:       03070793                addi    a5,a4,48
   103ac:       40f5272f                amoor.w a4,a5,(a0)
   103b0:       02071313                slli    t1,a4,0x20
   103b4:       fe034ce3                bltz    t1,0x103ac
   103b8:       36f1                    addiw   a3,a3,-4
   103ba:       fec690e3                bne     a3,a2,0x1039a
   103be:       2581                    sext.w  a1,a1
   103c0:       46f1                    li      a3,28
   103c2:       4825                    li      a6,9
   103c4:       5671                    li      a2,-4
   103c6:       00d5d73b                srlw    a4,a1,a3
   103ca:       8b3d                    andi    a4,a4,15
   103cc:       05770793                addi    a5,a4,87
   103d0:       00e86463                bltu    a6,a4,0x103d8
   103d4:       03070793                addi    a5,a4,48
   103d8:       40f5272f                amoor.w a4,a5,(a0)
   103dc:       02071893                slli    a7,a4,0x20
   103e0:       fe08cce3                bltz    a7,0x103d8
   103e4:       36f1                    addiw   a3,a3,-4
   103e6:       fec690e3                bne     a3,a2,0x103c6
   103ea:       8082                    ret


// load_spiflash_gpt_partition
   103ec:       da010113                addi    sp,sp,-608
   103f0:       23513423                sd      s5,552(sp)
   103f4:       23613023                sd      s6,544(sp)
   103f8:       8ab2                    mv      s5,a2       // partition_type_guid
   103fa:       8b2e                    mv      s6,a1
   103fc:       05c00693                li      a3,92
   10400:       20000613                li      a2,512
   10404:       080c                    addi    a1,sp,16 // gpt_buf
   10406:       23313c23                sd      s3,568(sp)
   1040a:       24113c23                sd      ra,600(sp)
   1040e:       24813823                sd      s0,592(sp)
   10412:       24913423                sd      s1,584(sp)
   10416:       25213023                sd      s2,576(sp)
   1041a:       23413823                sd      s4,560(sp)
   1041e:       21713c23                sd      s7,536(sp)
   10422:       89aa                    mv      s3,a0
   10424:       e53ff0ef                jal     ra,0x10276  // spi_copy
   10428:       e535                    bnez    a0,0x10494
   1042a:       5a16                    lw      s4,100(sp)  // partition_entry_size
   1042c:       5906                    lw      s2,96(sp)   // num_partition_entries
   1042e:       6466                    ld      s0,88(sp)   // partition_entries_lba
   10430:       0349093b                mulw    s2,s2,s4
   10434:       1ff9091b                addiw   s2,s2,511
   10438:       0099591b                srliw   s2,s2,0x9
   1043c:       1902                    slli    s2,s2,0x20
   1043e:       02095913                srli    s2,s2,0x20
   10442:       9922                    add     s2,s2,s0    // partition_entries_lba_end
   10444:       03247a63                bgeu    s0,s2,0x10478  // s0: i, loop first compare
   10448:       0094149b                slliw   s1,s0,0x9   // i * GPT_BLOCK_SIZE
   1044c:       20000b93                li      s7,512
   10450:       8626                    mv      a2,s1
   10452:       080c                    addi    a1,sp,16    // block_buf
   10454:       20000693                li      a3,512
   10458:       854e                    mv      a0,s3       // spictrl
   1045a:       e1dff0ef                jal     ra,0x10276  // spi_copy
   1045e:       034bd63b                divuw   a2,s7,s4    // GPT_BLOCK_SIZE / partition_entry_size
   10462:       85d6                    mv      a1,s5       // partition_type_guid
   10464:       0808                    addi    a0,sp,16    // block_buf
   10466:       0405                    addi    s0,s0,1     // i++
   10468:       2004849b                addiw   s1,s1,512   // (i + 1) * GPT_BLOCK_SIZE
   1046c:       514000ef                jal     ra,0x10980  // gpt_find_partition_by_guid
   10470:       c111                    beqz    a0,0x10474  // first_lba
   10472:       e589                    bnez    a1,0x1047c  // last_lba
   10474:       fd246ee3                bltu    s0,s2,0x10450  // i < partition_entries_lba_end
   10478:       450d                    li      a0,3     // ERROR_CODE_GPT_PARTITION_NOT_FOUND
   1047a:       a831                    j       0x10496
   1047c:       00158693                addi    a3,a1,1
   10480:       8e89                    sub     a3,a3,a0 // part_range.last_lba + 1 - part_range.first_lba
   10482:       0095161b                slliw   a2,a0,0x9
   10486:       0096969b                slliw   a3,a3,0x9
   1048a:       85da                    mv      a1,s6    // dst
   1048c:       854e                    mv      a0,s3    // spictrl
   1048e:       de9ff0ef                jal     ra,0x10276  // spi_copy
   10492:       c111                    beqz    a0,0x10496
   10494:       4511                    li      a0,4  // ERROR_CODE_SPI_COPY_FAILED
   10496:       25813083                ld      ra,600(sp)
   1049a:       25013403                ld      s0,592(sp)
   1049e:       24813483                ld      s1,584(sp)
   104a2:       24013903                ld      s2,576(sp)
   104a6:       23813983                ld      s3,568(sp)
   104aa:       23013a03                ld      s4,560(sp)
   104ae:       22813a83                ld      s5,552(sp)
   104b2:       22013b03                ld      s6,544(sp)
   104b6:       21813b83                ld      s7,536(sp)
   104ba:       26010113                addi    sp,sp,608
   104be:       8082                    ret

// load_sd_gpt_partition
   104c0:       db010113                addi    sp,sp,-592
   104c4:       23313423                sd      s3,552(sp)
   104c8:       21513c23                sd      s5,536(sp)
   104cc:       89b2                    mv      s3,a2
   104ce:       8aae                    mv      s5,a1
   104d0:       4685                    li      a3,1
   104d2:       4605                    li      a2,1
   104d4:       080c                    addi    a1,sp,16
   104d6:       23213823                sd      s2,560(sp)
   104da:       24113423                sd      ra,584(sp)
   104de:       24813023                sd      s0,576(sp)
   104e2:       22913c23                sd      s1,568(sp)
   104e6:       23413023                sd      s4,544(sp)
   104ea:       21613823                sd      s6,528(sp)
   104ee:       892a                    mv      s2,a0
   104f0:       01f000ef                jal     ra,0x10d0e  // sd_copy
   104f4:       c91d                    beqz    a0,0x1052a
   104f6:       4785                    li      a5,1  // decode_sd_copy_error
   104f8:       08f50b63                beq     a0,a5,0x1058e  // SD_COPY_ERROR_CMD18
   104fc:       4789                    li      a5,2
   104fe:       08f50663                beq     a0,a5,0x1058a  // SD_COPY_ERROR_CMD18_CRC
   10502:       4531                    li      a0,12    // ERROR_CODE_SD_CARD_UNEXPECTED_ERROR
   10504:       24813083                ld      ra,584(sp)
   10508:       24013403                ld      s0,576(sp)
   1050c:       23813483                ld      s1,568(sp)
   10510:       23013903                ld      s2,560(sp)
   10514:       22813983                ld      s3,552(sp)
   10518:       22013a03                ld      s4,544(sp)
   1051c:       21813a83                ld      s5,536(sp)
   10520:       21013b03                ld      s6,528(sp)
   10524:       25010113                addi    sp,sp,592
   10528:       8082                    ret
   1052a:       5a16                    lw      s4,100(sp)    // partition_entry_size
   1052c:       5486                    lw      s1,96(sp)     // num_partition_entries
   1052e:       6466                    ld      s0,88(sp)     // partition_entries_lba
   10530:       034484bb                mulw    s1,s1,s4
   10534:       1ff4849b                addiw   s1,s1,511
   10538:       0094d49b                srliw   s1,s1,0x9
   1053c:       1482                    slli    s1,s1,0x20
   1053e:       9081                    srli    s1,s1,0x20
   10540:       94a2                    add     s1,s1,s0    // partition_entries_lba_end
   10542:       04947a63                bgeu    s0,s1,0x10596  // s0: i
   10546:       20000b13                li      s6,512
   1054a:       0004061b                sext.w  a2,s0       // begin for
   1054e:       080c                    addi    a1,sp,16    // block_buf
   10550:       4685                    li      a3,1
   10552:       854a                    mv      a0,s2       // spictrl
   10554:       7ba000ef                jal     ra,0x10d0e  // sd_copy
   10558:       034b563b                divuw   a2,s6,s4    // GPT_BLOCK_SIZE / partition_entry_size
   1055c:       85ce                    mv      a1,s3       // partition_type_guid
   1055e:       0808                    addi    a0,sp,16    // block_buf
   10560:       0405                    addi    s0,s0,1     // i++
   10562:       41e000ef                jal     ra,0x10980  // gpt_find_partition_by_guid
   10566:       c515                    beqz    a0,0x10592  // first_lba
   10568:       c58d                    beqz    a1,0x10592  // last_lba
   1056a:       00158693                addi    a3,a1,1
   1056e:       8e89                    sub     a3,a3,a0    // part_range.last_lba + 1 - part_range.first_lba
   10570:       0005061b                sext.w  a2,a0       // part_range.first_lba
   10574:       85d6                    mv      a1,s5       // dst
   10576:       854a                    mv      a0,s2       // spictrl
   10578:       796000ef                jal     ra,0x10d0e  // sd_copy
   1057c:       d541                    beqz    a0,0x10504  // return
   1057e:       4705                    li      a4,1
   10580:       00e50763                beq     a0,a4,0x1058e  // SD_COPY_ERROR_CMD18
   10584:       4709                    li      a4,2
   10586:       f6e51ee3                bne     a0,a4,0x10502  // SD_COPY_ERROR_CMD18_CRC
   1058a:       452d                    li      a0,11    // ERROR_CODE_SD_CARD_CMD18_CRC
   1058c:       bfa5                    j       0x10504  // return
   1058e:       4529                    li      a0,10    // ERROR_CODE_SD_CARD_CMD18
   10590:       bf95                    j       0x10504  // return
   10592:       fa946ce3                bltu    s0,s1,0x1054a  // next loop
   10596:       450d                    li      a0,3     // ERROR_CODE_GPT_PARTITION_NOT_FOUND
   10598:       b7b5                    j       0x10504  // return


// load_mmap_gpt_partition
   1059a:       7179                    addi    sp,sp,-48
   1059c:       f022                    sd      s0,32(sp)
   1059e:       842a                    mv      s0,a0       // gpt_base
   105a0:       24853503                ld      a0,584(a0)  // header->partition_entries_lba
   105a4:       8732                    mv      a4,a2       // partition_type_guid
   105a6:       25042603                lw      a2,592(s0)  // header->num_partition_entries
   105aa:       0526                    slli    a0,a0,0x9   // header->partition_entries_lba * GPT_BLOCK_SIZE
   105ac:       ec26                    sd      s1,24(sp)
   105ae:       9522                    add     a0,a0,s0    // gpt_base + header->partition_entries_lba * GPT_BLOCK_SIZE
   105b0:       84ae                    mv      s1,a1
   105b2:       85ba                    mv      a1,a4       // partition_type_guid
   105b4:       f406                    sd      ra,40(sp)
   105b6:       3ca000ef                jal     ra,0x10980  // gpt_find_partition_by_guid
   105ba:       e02a                    sd      a0,0(sp)    // first_lba
   105bc:       e42e                    sd      a1,8(sp)    // last_lba
   105be:       c909                    beqz    a0,0x105d0  // first_lba
   105c0:       87aa                    mv      a5,a0       // first_lba
   105c2:       450d                    li      a0,3        // ERROR_CODE_GPT_PARTITION_NOT_FOUND
   105c4:       ed81                    bnez    a1,0x105dc  // last_lba
   105c6:       70a2                    ld      ra,40(sp)
   105c8:       7402                    ld      s0,32(sp)
   105ca:       64e2                    ld      s1,24(sp)
   105cc:       6145                    addi    sp,sp,48
   105ce:       8082                    ret
   105d0:       70a2                    ld      ra,40(sp)
   105d2:       7402                    ld      s0,32(sp)
   105d4:       64e2                    ld      s1,24(sp)
   105d6:       450d                    li      a0,3        // ERROR_CODE_GPT_PARTITION_NOT_FOUND
   105d8:       6145                    addi    sp,sp,48
   105da:       8082                    ret

   // DMA
   105dc:       030806b7                lui     a3,0x3080
   105e0:       4705                    li      a4,1
   105e2:       00e68023                sb      a4,0(a3) # 0x3080000 // DMA
   105e6:       4298                    lw      a4,0(a3)
   105e8:       01e7571b                srliw   a4,a4,0x1e  // >> 30
   105ec:       2701                    sext.w  a4,a4
   105ee:       c719                    beqz    a4,0x105fc
   105f0:       4501                    li      a0,0        // return 0
   105f2:       70a2                    ld      ra,40(sp)
   105f4:       7402                    ld      s0,32(sp)
   105f6:       64e2                    ld      s1,24(sp)
   105f8:       6145                    addi    sp,sp,48
   105fa:       8082                    ret

   105fc:       0585                    addi    a1,a1,1     // range.last_lba + 1
   105fe:       8d9d                    sub     a1,a1,a5    // range.last_lba + 1 - range.first_lba
   10600:       05a6                    slli    a1,a1,0x9   // (range.last_lba + 1 - range.first_lba) * GPT_BLOCK_SIZE
   10602:       e68c                    sd      a1,8(a3)    // PDMA0.NextBytes = (range.last_lba + 1 - range.first_lba) * GPT_BLOCK_SIZE
   10604:       07a6                    slli    a5,a5,0x9   // range.first_lba * GPT_BLOCK_SIZE
   10606:       ea84                    sd      s1,16(a3)   // PDMA0.NextDestination = payload_dest
   10608:       97a2                    add     a5,a5,s0    // gpt_base + range.first_lba * GPT_BLOCK_SIZE
   1060a:       ee9c                    sd      a5,24(a3)   // PDMA0.NextSource = gpt_base + range.first_lba * GPT_BLOCK_SIZE
   1060c:       3f0007b7                lui     a5,0x3f000
   10610:       27a1                    addiw   a5,a5,8     // 0x3f00_0008
   10612:       c2dc                    sw      a5,4(a3)    // PDMA0.NextConfig = 0x3f00_0008 (order, wsize = 2^f, rsize=2^3)
   10614:       00a68023                sb      a0,0(a3)    // PDMA0.Control = 0x3 (run = 1)
   10618:       03080737                lui     a4,0x3080
   1061c:       431c                    lw      a5,0(a4)    // 0x3080_0000
   1061e:       8b89                    andi    a5,a5,2     // PDMA0.run ?
   10620:       fff5                    bnez    a5,0x1061c  // if running, read and check again
   10622:       431c                    lw      a5,0(a4)    // 0x3080_0000
   10624:       4685                    li      a3,1
   10626:       01e7d79b                srliw   a5,a5,0x1e  // >> 30
   1062a:       2781                    sext.w  a5,a5
   1062c:       fcd792e3                bne     a5,a3,0x105f0  // branch if not done, return 0
   10630:       00070023                sb      zero,0(a4) # 0x3080000
   10634:       4501                    li      a0,0
   10636:       bf75                    j       0x105f2     // return 0


// ?? DMA
   10638:       03080737                lui     a4,0x3080
   1063c:       4785                    li      a5,1
   1063e:       00f70023                sb      a5,0(a4) # 0x3080000
   10642:       431c                    lw      a5,0(a4)
   10644:       01e7d79b                srliw   a5,a5,0x1e
   10648:       2781                    sext.w  a5,a5
   1064a:       ef85                    bnez    a5,0x10682
   1064c:       e70c                    sd      a1,8(a4)
   1064e:       eb08                    sd      a0,16(a4)
   10650:       090007b7                lui     a5,0x9000
   10654:       ef1c                    sd      a5,24(a4)
   10656:       ff0007b7                lui     a5,0xff000
   1065a:       c35c                    sw      a5,4(a4)
   1065c:       478d                    li      a5,3
   1065e:       00f70023                sb      a5,0(a4)
   10662:       03080737                lui     a4,0x3080
   10666:       431c                    lw      a5,0(a4)
   10668:       8b89                    andi    a5,a5,2
   1066a:       fff5                    bnez    a5,0x10666
   1066c:       431c                    lw      a5,0(a4)
   1066e:       4685                    li      a3,1
   10670:       01e7d79b                srliw   a5,a5,0x1e
   10674:       2781                    sext.w  a5,a5
   10676:       00d79663                bne     a5,a3,0x10682
   1067a:       00070023                sb      zero,0(a4) # 0x3080000
   1067e:       4501                    li      a0,0
   10680:       8082                    ret
   10682:       4535                    li      a0,13
   10684:       8082                    ret


// ux00boot_fail
   10686:       1141                    addi    sp,sp,-16
   10688:       e406                    sd      ra,8(sp)
   1068a:       e022                    sd      s0,0(sp)
   1068c:       f14027f3                csrr    a5,mhartid
   10690:       e7a1                    bnez    a5,0x106d8  // if (read_csr(mhartid) == NONSMP_HART)
   10692:       100107b7                lui     a5,0x10010
   10696:       4705                    li      a4,1
   10698:       c798                    sw      a4,8(a5)    // UART0_REG(UART_REG_TXCTRL) = UART_TXEN;
   1069a:       87aa                    mv      a5,a0       // code
   1069c:       c599                    beqz    a1,0x106aa  // if (trap != 0)
   1069e:       00055663                bgez    a0,0x106aa  // if (code < 0)
   106a2:       4705                    li      a4,1
   106a4:       175e                    slli    a4,a4,0x37  // 1 << 55
   106a6:       00e567b3                or      a5,a0,a4    // code | (1 << 55)
   106aa:       03859413                slli    s0,a1,0x38  // trap << 56
   106ae:       10010537                lui     a0,0x10010
   106b2:       00003597                auipc   a1,0x3
   106b6:       09658593                addi    a1,a1,150 # 0x13748  // "Error 0x"
   106ba:       8c5d                    or      s0,s0,a5    // code | if code < 0 (1 << 55) | trap << 56
   106bc:       c8dff0ef                jal     ra,0x10348     // uart_puts
   106c0:       42045593                srai    a1,s0,0x20  // (code | if code < 0 (1 << 55) | trap << 56) >> 32
   106c4:       10010537                lui     a0,0x10010
   106c8:       c9dff0ef                jal     ra,0x10364     // uart_put_hex
   106cc:       0004059b                sext.w  a1,s0
   106d0:       10010537                lui     a0,0x10010
   106d4:       c91ff0ef                jal     ra,0x10364     // uart_put_hex
   106d8:       100607b7                lui     a5,0x10060
   106dc:       00c78693                addi    a3,a5,12 # 0x1006000c   // GPIO_OUTPUT_VAL
   106e0:       6721                    lui     a4,0x8      // 1 << 15
   106e2:       0f50000f                fence   iorw,ow
   106e6:       44e6a02f                amoor.w.aq      zero,a4,(a3)
   106ea:       00878693                addi    a3,a5,8     // GPIO_OUTPUT_EN
   106ee:       0f50000f                fence   iorw,ow
   106f2:       44e6a02f                amoor.w.aq      zero,a4,(a3)
   106f6:       04078793                addi    a5,a5,64    // GPIO_OUTPUT_XOR
   106fa:       0f50000f                fence   iorw,ow
   106fe:       44e7a02f                amoor.w.aq      zero,a4,(a5)
   10702:       a001                    j       0x10702     // while (1)


// ux00boot_load_gpt_partition
   10704:       6785                    lui     a5,0x1      // MODESELECT_MEM_ADDR
   10706:       439c                    lw      a5,0(a5)    // mode_select
   10708:       7139                    addi    sp,sp,-64
   1070a:       fc06                    sd      ra,56(sp)
   1070c:       2781                    sext.w  a5,a5
   1070e:       f822                    sd      s0,48(sp)
   10710:       f426                    sd      s1,40(sp)
   10712:       f04a                    sd      s2,32(sp)
   10714:       ec4e                    sd      s3,24(sp)
   10716:       e852                    sd      s4,16(sp)
   10718:       e456                    sd      s5,8(sp)
   1071a:       e05a                    sd      s6,0(sp)
   1071c:       4729                    li      a4,10       // a4 = 10
   1071e:       ffb7869b                addiw   a3,a5,-5    // a3 = mode_select - 5
   10722:       00d77663                bgeu    a4,a3,0x1072e  // if (15 < mode_select) {...} else goto 1f
2:
   10726:       4581                    li      a1,0
   10728:       4505                    li      a0,1
   1072a:       f5dff0ef                jal     ra,0x10686  // ux00boot_fail(ERROR_CODE_UNHANDLED_SPI_DEVICE, 0)
1:
   1072e:       4705                    li      a4,         // a4 = 1
   10730:       00d71733                sll     a4,a4,a3    // a4 = 1 << (mode_select - 5)
   10734:       62377693                andi    a3,a4,1571  // a3 = (1 << (mode_select - 5)) & 0b 0000_0110_0010_0011, mode_select in {5, 6, 10, 14, 15} // SPI0
   10738:       84aa                    mv      s1,a0       // dst
   1073a:       892e                    mv      s2,a1       // partition_type_guid
   1073c:       8432                    mv      s0,a2       // peripheral_input_khz
   1073e:       ea85                    bnez    a3,0x1076e  // if (a3 == 0) {...} else goto 1f, mode_select in {5, 6, 10, 14, 15}   // SPI0
   10740:       05077693                andi    a3,a4,80    // a3 = (1 << (mode_select - 5)) & 0b 0000_0000_0101_0000, mode_select in {9, 11}   // SPI2
   10744:       e6b1                    bnez    a3,0x10790  // if (a3 == 0) {...} else goto 2f, mode_select in {9, 11}   // SPI2
   10746:       18c77713                andi    a4,a4,396   // a4 = (1 << (mode_select - 5)) & 0b 0000_0001_1000_1100, mode_select in {7, 8, 12, 13}   // SPI1
   1074a:       df71                    beqz    a4,0x10726  // if (a4 != 0) {...} else goto 2b, mode_select in {7, 8, 12, 13}   // SPI1
   // SPI1
   1074c:       37e9                    addiw   a5,a5,-6    // a5 = mode_select - 6
   1074e:       0007869b                sext.w  a3,a5       // a3 = mode_select - 6
   10752:       4725                    li      a4,9        // a4 = 9
   10754:       18d76363                bltu    a4,a3,0x108da  // if (9 >= (mode_select - 6)) {...} else goto 3f     // (15 >= (mode_select))
   10758:       1782                    slli    a5,a5,0x20
   1075a:       9381                    srli    a5,a5,0x20  // a5 drop high 32 bits
   1075c:       00003717                auipc   a4,0x3
   10760:       f5c70713                addi    a4,a4,-164 # 0x136b8
   10764:       078a                    slli    a5,a5,0x2   // a5 = (mode_select - 6) << 2
   10766:       97ba                    add     a5,a5,a4    // a5 += 0x136b8
   10768:       439c                    lw      a5,0(a5)    // a5 = *a5
   1076a:       97ba                    add     a5,a5,a4    // a5 += 0x136b8
   1076c:       8782                    jr      a5          // a5()
                                                            // mode_select target
                                                            //      7        j1  MQ
                                                            //      8        j2  SD
                                                            //     12        j3  BB
                                                            //     13        j1  MQ
1: // SPI0
   1076e:       37e9                    addiw   a5,a5,-6
   10770:       0007869b                sext.w  a3,a5
   10774:       4725                    li      a4,9
   10776:       02d76e63                bltu    a4,a3,0x107b2  // if (9 >= (mode_select - 6)) {...} else goto 4f  boot_routine: UX00BOOT_ROUTINE_MMAP
   1077a:       1782                    slli    a5,a5,0x20
   1077c:       9381                    srli    a5,a5,0x20
   1077e:       00003717                auipc   a4,0x3
   10782:       f6270713                addi    a4,a4,-158 # 0x136e0
   10786:       078a                    slli    a5,a5,0x2
   10788:       97ba                    add     a5,a5,a4
   1078a:       439c                    lw      a5,0(a5)
   1078c:       97ba                    add     a5,a5,a4
   1078e:       8782                    jr      a5
                                                            // mode_select target
                                                            //      5        4f  M
                                                            //      6        j4  MQ
                                                            //     10        j4  MQ
                                                            //     14        j4  BB
                                                            //     15        j4  MQ
2: // SPI2
   10790:       37e9                    addiw   a5,a5,-6
   10792:       0007869b                sext.w  a3,a5
   10796:       4725                    li      a4,9
   10798:       14d76b63                bltu    a4,a3,0x108ee  // if (9 >= (mode_select - 6)) {...} else goto 5f
   1079c:       1782                    slli    a5,a5,0x20
   1079e:       9381                    srli    a5,a5,0x20
   107a0:       00003717                auipc   a4,0x3
   107a4:       f6870713                addi    a4,a4,-152 # 0x13708
   107a8:       078a                    slli    a5,a5,0x2
   107aa:       97ba                    add     a5,a5,a4
   107ac:       439c                    lw      a5,0(a5)
   107ae:       97ba                    add     a5,a5,a4
   107b0:       8782                    jr      a5
                                                            // mode_select target
                                                            //      9        j5  BB
                                                            //     11        j6  SD
   
   // boot_routine: UX00BOOT_ROUTINE_MMAP
   // inlined initialize_spi_flash_mmap_single
4:
   107b2:       20000a37                lui     s4,0x20000  // SPI 0
   107b6:       100409b7                lui     s3,0x10040  // QSPI0
10:
   107ba:       6715                    lui     a4,0x5
   107bc:       e1f7079b                addiw   a5,a4,-481  // 19999
   107c0:       9c3d                    addw    s0,s0,a5    // peripheral_input_khz + 19999
   107c2:       e207071b                addiw   a4,a4,-480  // 20000
   107c6:       02e457bb                divuw   a5,s0,a4    // a5 = (peripheral_input_khz + 19999) / 20000
   107ca:       c391                    beqz    a5,0x107ce  // if (a5 != 0) {...} else goto 1f
   107cc:       37fd                    addiw   a5,a5,-1    // a5 -= 1;
1:
   107ce:       00f9a023                sw      a5,0(s3) # 0x10040000   // QSPI0.sckdiv
   107d2:       0609a783                lw      a5,96(s3)   // 0x60 QSPI0.fctrl (bit0: en)
   107d6:       06600593                li      a1,102      // 0x66 MICRON_SPI_FLASH_CMD_RESET_ENABLE
   107da:       854e                    mv      a0,s3       // spictrl = QSPI0
   107dc:       9bf9                    andi    a5,a5,-2    // QSPI0.fctrl clear en
   107de:       06f9a023                sw      a5,96(s3)   // 0x60 QSPI0.fctrl.en = 0
   107e2:       a77ff0ef                jal     ra,0x10258  // spi_txrx(QSPI0, MICRON_SPI_FLASH_CMD_RESET_ENABLE)
   107e6:       09900593                li      a1,153      // 0x99 MICRON_SPI_FLASH_CMD_MEMORY_RESET
   107ea:       854e                    mv      a0,s3
   107ec:       a6dff0ef                jal     ra,0x10258  // spi_txrx(QSPI0, MICRON_SPI_FLASH_CMD_MEMORY_RESET)
   107f0:       000307b7                lui     a5,0x30
   107f4:       0077e793                ori     a5,a5,7     // 0x00030007, as below
                                                            // .cmd_en = 1,
                                                            // .addr_len = 3,
                                                            // .pad_cnt = 0,
                                                            // .command_proto = 0, SPI_PROTO_S,
                                                            // .addr_proto = 0, SPI_PROTO_S,
                                                            // .data_proto = 0, SPI_PROTO_S,
                                                            // .command_code = 3, MICRON_SPI_FLASH_CMD_READ,
                                                            // .pad_code = 0
   107f8:       06f9a223                sw      a5,100(s3)  // 0x64 QSPI0.ffmt
   107fc:       0609a783                lw      a5,96(s3)   // 0x60 QSPI0.fctrl
   10800:       0017e793                ori     a5,a5,1
   10804:       06f9a023                sw      a5,96(s3)   // 0x60 QSPI0.fctrl.en = 1
   10808:       0cc0000f                fence   io,io
   1080c:       864a                    mv      a2,s2       // partition_type_guid
   1080e:       85a6                    mv      a1,s1       // dst
   10810:       8552                    mv      a0,s4       // spimem = 0x2000_0000 (SPI 0)
   10812:       d89ff0ef                jal     ra,0x1059a  // load_mmap_gpt_partition(spimem, dst, partition_type_guid)
   10816:       2501                    sext.w  a0,a0
   10818:       e15d                    bnez    a0,0x108be  // if (ret == 0) {...} else goto 1f
   1081a:       70e2                    ld      ra,56(sp)
   1081c:       7442                    ld      s0,48(sp)
   1081e:       74a2                    ld      s1,40(sp)
   10820:       7902                    ld      s2,32(sp)
   10822:       69e2                    ld      s3,24(sp)
   10824:       6a42                    ld      s4,16(sp)
   10826:       6aa2                    ld      s5,8(sp)
   10828:       6b02                    ld      s6,0(sp)
   1082a:       6121                    addi    sp,sp,64
   1082c:       8082                    ret                 // return
j4:
   1082e:       4781                    li      a5,0
9:
   10830:       e3f9                    bnez    a5,0x108f6
   10832:       20000a37                lui     s4,0x20000
   10836:       100409b7                lui     s3,0x10040
7:
   1083a:       6715                    lui     a4,0x5
   1083c:       e1f7079b                addiw   a5,a4,-481
   10840:       9c3d                    addw    s0,s0,a5
   10842:       e207071b                addiw   a4,a4,-480
   10846:       02e457bb                divuw   a5,s0,a4
   1084a:       c391                    beqz    a5,0x1084e
   1084c:       37fd                    addiw   a5,a5,-1
   1084e:       00f9a023                sw      a5,0(s3) # 0x10040000
   10852:       0609a783                lw      a5,96(s3)
   10856:       06600593                li      a1,102
   1085a:       854e                    mv      a0,s3
   1085c:       9bf9                    andi    a5,a5,-2
   1085e:       06f9a023                sw      a5,96(s3)
   10862:       9f7ff0ef                jal     ra,0x10258
   10866:       09900593                li      a1,153
   1086a:       854e                    mv      a0,s3
   1086c:       9edff0ef                jal     ra,0x10258
   10870:       006b27b7                lui     a5,0x6b2
   10874:       08778793                addi    a5,a5,135 # 0x6b2087
   10878:       b741                    j       0x107f8
   1087a:       10040a37                lui     s4,0x10040
6:
   1087e:       49c1                    li      s3,16
   10880:       4a91                    li      s5,4
   10882:       00003b17                auipc   s6,0x3
   10886:       eaeb0b13                addi    s6,s6,-338 # 0x13730
   1088a:       4601                    li      a2,0
   1088c:       85a2                    mv      a1,s0
   1088e:       8552                    mv      a0,s4
   10890:       2c4000ef                jal     ra,0x10b54  // ???
   10894:       e901                    bnez    a0,0x108a4
b:
   10896:       864a                    mv      a2,s2
   10898:       85a6                    mv      a1,s1
   1089a:       8552                    mv      a0,s4
   1089c:       c25ff0ef                jal     ra,0x104c0
   108a0:       2501                    sext.w  a0,a0
   108a2:       bf9d                    j       0x10818
   108a4:       357d                    addiw   a0,a0,-1
   108a6:       0005079b                sext.w  a5,a0
   108aa:       00faef63                bltu    s5,a5,0x108c8  // if (5 >= a0) {...} else goto a
   108ae:       1502                    slli    a0,a0,0x20     // << 32
   108b0:       8179                    srli    a0,a0,0x1e     // >> 30
   108b2:       955a                    add     a0,a0,s6       // a0 += 0x13730
   108b4:       4108                    lw      a0,0(a0)       // a0 = *a0
   108b6:       d165                    beqz    a0,0x10896     // if (a0 != 0) {...} else goto b
8:
   108b8:       19fd                    addi    s3,s3,-1
   108ba:       fc0998e3                bnez    s3,0x1088a
1:
   108be:       1502                    slli    a0,a0,0x20
   108c0:       4581                    li      a1,0
   108c2:       9101                    srli    a0,a0,0x20
   108c4:       dc3ff0ef                jal     ra,0x10686  // ux00boot_fail(ret, 0)
a:
   108c8:       4531                    li      a0,12
   108ca:       b7fd                    j       0x108b8     // goto 8b
   108cc:       4a01                    li      s4,0
   108ce:       100509b7                lui     s3,0x10050
   108d2:       b7a5                    j       0x1083a     // goto 7b
j6:
   108d4:       10050a37                lui     s4,0x10050
   108d8:       b75d                    j       0x1087e     // goto 6b
3:
   108da:       30000a37                lui     s4,0x30000  // spimem = 0x3000_0000 SPI1
   108de:       100419b7                lui     s3,0x10041  // QSPI1
   108e2:       bde1                    j       0x107ba     // goto 10b
j1:
   108e4:       4785                    li      a5,1
   108e6:       b7a9                    j       0x10830     // goto 9b
j2:
   108e8:       10041a37                lui     s4,0x10041
   108ec:       bf49                    j       0x1087e     // goto 6b
5:
   108ee:       4a01                    li      s4,0        // spimem = 0x0000_0000
   108f0:       100509b7                lui     s3,0x10050  // QSPI2
   108f4:       b5d9                    j       0x107ba     // goto 10b
   108f6:       30000a37                lui     s4,0x30000
   108fa:       100419b7                lui     s3,0x10041
   108fe:       bf35                    j       0x1083a     // goto 7b
   10900:       100409b7                lui     s3,0x10040
   10904:       6715                    lui     a4,0x5
   10906:       e1f7079b                addiw   a5,a4,-481
   1090a:       9c3d                    addw    s0,s0,a5
   1090c:       e207071b                addiw   a4,a4,-480
   10910:       02e457bb                divuw   a5,s0,a4
   10914:       c391                    beqz    a5,0x10918
   10916:       37fd                    addiw   a5,a5,-1
   10918:       00f9a023                sw      a5,0(s3) # 0x10040000
   1091c:       0609a783                lw      a5,96(s3)
   10920:       06600593                li      a1,102
   10924:       854e                    mv      a0,s3
   10926:       9bf9                    andi    a5,a5,-2
   10928:       06f9a023                sw      a5,96(s3)
   1092c:       92dff0ef                jal     ra,0x10258
   10930:       09900593                li      a1,153
   10934:       854e                    mv      a0,s3
   10936:       923ff0ef                jal     ra,0x10258
   1093a:       864a                    mv      a2,s2
   1093c:       85a6                    mv      a1,s1
   1093e:       854e                    mv      a0,s3
   10940:       aadff0ef                jal     ra,0x103ec
   10944:       2501                    sext.w  a0,a0
   10946:       bdc9                    j       0x10818
j3:
   10948:       100419b7                lui     s3,0x10041
   1094c:       bf65                    j       0x10904
j5:
   1094e:       100509b7                lui     s3,0x10050
   10952:       bf4d                    j       0x10904
   10954:       0200c7b7                lui     a5,0x200c
   10958:       ff87b503                ld      a0,-8(a5) # 0x200bff8
   1095c:       8082                    ret
   1095e:       3e800793                li      a5,1000
   10962:       02f55533                divu    a0,a0,a5
   10966:       0200c7b7                lui     a5,0x200c
   1096a:       ff87b783                ld      a5,-8(a5) # 0x200bff8
   1096e:       0200c737                lui     a4,0x200c
   10972:       0785                    addi    a5,a5,1
   10974:       953e                    add     a0,a0,a5
   10976:       ff873783                ld      a5,-8(a4) # 0x200bff8
   1097a:       fea7eee3                bltu    a5,a0,0x10976
   1097e:       8082                    ret


// gpt_find_partition_by_guid
   10980:       1141                    addi    sp,sp,-16
   10982:       ce05                    beqz    a2,0x109ba
   10984:       fff6089b                addiw   a7,a2,-1
   10988:       1882                    slli    a7,a7,0x20
   1098a:       0198d893                srli    a7,a7,0x19
   1098e:       98aa                    add     a7,a7,a0
   10990:       08088893                addi    a7,a7,128
   10994:       872e                    mv      a4,a1
   10996:       01050813                addi    a6,a0,16 # 0x10010010
   1099a:       87aa                    mv      a5,a0
   1099c:       a019                    j       0x109a2
   1099e:       03078463                beq     a5,a6,0x109c6
   109a2:       0007c603                lbu     a2,0(a5)
   109a6:       00074683                lbu     a3,0(a4)
   109aa:       0785                    addi    a5,a5,1
   109ac:       0705                    addi    a4,a4,1
   109ae:       fed608e3                beq     a2,a3,0x1099e
   109b2:       08050513                addi    a0,a0,128
   109b6:       fd151fe3                bne     a0,a7,0x10994
   109ba:       e002                    sd      zero,0(sp)
   109bc:       e402                    sd      zero,8(sp)
   109be:       6502                    ld      a0,0(sp)
   109c0:       65a2                    ld      a1,8(sp)
   109c2:       0141                    addi    sp,sp,16
   109c4:       8082                    ret
   109c6:       7518                    ld      a4,40(a0)
   109c8:       711c                    ld      a5,32(a0)
   109ca:       e43a                    sd      a4,8(sp)
   109cc:       e03e                    sd      a5,0(sp)
   109ce:       6502                    ld      a0,0(sp)
   109d0:       65a2                    ld      a1,8(sp)
   109d2:       0141                    addi    sp,sp,16
   109d4:       8082                    ret
   109d6:       00a5c7b3                xor     a5,a1,a0
   109da:       8b9d                    andi    a5,a5,7
   109dc:       00c508b3                add     a7,a0,a2
   109e0:       e7a1                    bnez    a5,0x10a28
   109e2:       479d                    li      a5,7
   109e4:       04c7f263                bgeu    a5,a2,0x10a28
   109e8:       00757713                andi    a4,a0,7
   109ec:       87aa                    mv      a5,a0
   109ee:       eb29                    bnez    a4,0x10a40
   109f0:       ff88f813                andi    a6,a7,-8
   109f4:       fc080713                addi    a4,a6,-64
   109f8:       06e7e763                bltu    a5,a4,0x10a66
   109fc:       86ae                    mv      a3,a1
   109fe:       873e                    mv      a4,a5
   10a00:       0307f163                bgeu    a5,a6,0x10a22
   10a04:       6290                    ld      a2,0(a3)
   10a06:       0721                    addi    a4,a4,8
   10a08:       06a1                    addi    a3,a3,8
   10a0a:       fec73c23                sd      a2,-8(a4)
   10a0e:       ff076be3                bltu    a4,a6,0x10a04
   10a12:       fff7c713                not     a4,a5
   10a16:       983a                    add     a6,a6,a4
   10a18:       ff887813                andi    a6,a6,-8
   10a1c:       0821                    addi    a6,a6,8
   10a1e:       97c2                    add     a5,a5,a6
   10a20:       95c2                    add     a1,a1,a6
   10a22:       0117e663                bltu    a5,a7,0x10a2e
   10a26:       8082                    ret
   10a28:       87aa                    mv      a5,a0
   10a2a:       ff157ee3                bgeu    a0,a7,0x10a26
   10a2e:       0005c703                lbu     a4,0(a1)
   10a32:       0785                    addi    a5,a5,1
   10a34:       0585                    addi    a1,a1,1
   10a36:       fee78fa3                sb      a4,-1(a5)
   10a3a:       ff17eae3                bltu    a5,a7,0x10a2e
   10a3e:       8082                    ret
   10a40:       0005c683                lbu     a3,0(a1)
   10a44:       0785                    addi    a5,a5,1
   10a46:       0077f713                andi    a4,a5,7
   10a4a:       fed78fa3                sb      a3,-1(a5)
   10a4e:       0585                    addi    a1,a1,1
   10a50:       d345                    beqz    a4,0x109f0
   10a52:       0005c683                lbu     a3,0(a1)
   10a56:       0785                    addi    a5,a5,1
   10a58:       0077f713                andi    a4,a5,7
   10a5c:       fed78fa3                sb      a3,-1(a5)
   10a60:       0585                    addi    a1,a1,1
   10a62:       ff79                    bnez    a4,0x10a40
   10a64:       b771                    j       0x109f0
   10a66:       0005b383                ld      t2,0(a1)
   10a6a:       0085b283                ld      t0,8(a1)
   10a6e:       0105bf83                ld      t6,16(a1)
   10a72:       0185bf03                ld      t5,24(a1)
   10a76:       0205be83                ld      t4,32(a1)
   10a7a:       0285be03                ld      t3,40(a1)
   10a7e:       0305b303                ld      t1,48(a1)
   10a82:       7d90                    ld      a2,56(a1)
   10a84:       04858593                addi    a1,a1,72
   10a88:       04878793                addi    a5,a5,72
   10a8c:       ff85b683                ld      a3,-8(a1)
   10a90:       fa77bc23                sd      t2,-72(a5)
   10a94:       fc57b023                sd      t0,-64(a5)
   10a98:       fdf7b423                sd      t6,-56(a5)
   10a9c:       fde7b823                sd      t5,-48(a5)
   10aa0:       fdd7bc23                sd      t4,-40(a5)
   10aa4:       ffc7b023                sd      t3,-32(a5)
   10aa8:       fe67b423                sd      t1,-24(a5)
   10aac:       fec7b823                sd      a2,-16(a5)
   10ab0:       fed7bc23                sd      a3,-8(a5)
   10ab4:       fae7e9e3                bltu    a5,a4,0x10a66
   10ab8:       b791                    j       0x109fc
   10aba:       7179                    addi    sp,sp,-48
   10abc:       f406                    sd      ra,40(sp)
   10abe:       f022                    sd      s0,32(sp)
   10ac0:       ec26                    sd      s1,24(sp)
   10ac2:       e84a                    sd      s2,16(sp)
   10ac4:       e44e                    sd      s3,8(sp)
   10ac6:       4d1c                    lw      a5,24(a0)
   10ac8:       89ae                    mv      s3,a1
   10aca:       0ff00593                li      a1,255
   10ace:       9bf1                    andi    a5,a5,-4
   10ad0:       0027e793                ori     a5,a5,2
   10ad4:       cd1c                    sw      a5,24(a0)
   10ad6:       8432                    mv      s0,a2
   10ad8:       8936                    mv      s2,a3
   10ada:       84aa                    mv      s1,a0
   10adc:       f7cff0ef                jal     ra,0x10258
   10ae0:       85ce                    mv      a1,s3
   10ae2:       8526                    mv      a0,s1
   10ae4:       f74ff0ef                jal     ra,0x10258
   10ae8:       0184559b                srliw   a1,s0,0x18
   10aec:       0ff5f593                andi    a1,a1,255
   10af0:       8526                    mv      a0,s1
   10af2:       f66ff0ef                jal     ra,0x10258
   10af6:       0104559b                srliw   a1,s0,0x10
   10afa:       0ff5f593                andi    a1,a1,255
   10afe:       8526                    mv      a0,s1
   10b00:       f58ff0ef                jal     ra,0x10258
   10b04:       0084559b                srliw   a1,s0,0x8
   10b08:       0ff5f593                andi    a1,a1,255
   10b0c:       8526                    mv      a0,s1
   10b0e:       f4aff0ef                jal     ra,0x10258
   10b12:       0ff47593                andi    a1,s0,255
   10b16:       8526                    mv      a0,s1
   10b18:       f40ff0ef                jal     ra,0x10258
   10b1c:       85ca                    mv      a1,s2
   10b1e:       8526                    mv      a0,s1
   10b20:       f38ff0ef                jal     ra,0x10258
   10b24:       3e800413                li      s0,1000
   10b28:       a011                    j       0x10b2c
   10b2a:       cc09                    beqz    s0,0x10b44
   10b2c:       0ff00593                li      a1,255
   10b30:       8526                    mv      a0,s1
   10b32:       f26ff0ef                jal     ra,0x10258
   10b36:       0185179b                slliw   a5,a0,0x18
   10b3a:       4187d79b                sraiw   a5,a5,0x18
   10b3e:       147d                    addi    s0,s0,-1
   10b40:       fe07c5e3                bltz    a5,0x10b2a
   10b44:       70a2                    ld      ra,40(sp)
   10b46:       7402                    ld      s0,32(sp)
   10b48:       64e2                    ld      s1,24(sp)
   10b4a:       6942                    ld      s2,16(sp)
   10b4c:       69a2                    ld      s3,8(sp)
   10b4e:       2501                    sext.w  a0,a0
   10b50:       6145                    addi    sp,sp,48
   10b52:       8082                    ret


// ???
   10b54:       7179                    addi    sp,sp,-48
   10b56:       f022                    sd      s0,32(sp)
   10b58:       e84a                    sd      s2,16(sp)
   10b5a:       f406                    sd      ra,40(sp)
   10b5c:       ec26                    sd      s1,24(sp)
   10b5e:       e44e                    sd      s3,8(sp)
   10b60:       842a                    mv      s0,a0
   10b62:       892e                    mv      s2,a1
   10b64:       c615                    beqz    a2,0x10b90
   10b66:       67a9                    lui     a5,0xa
   10b68:       c3f7859b                addiw   a1,a5,-961
   10b6c:       00b905bb                addw    a1,s2,a1
   10b70:       c407879b                addiw   a5,a5,-960
   10b74:       02f5d7bb                divuw   a5,a1,a5
   10b78:       eb91                    bnez    a5,0x10b8c
   10b7a:       c01c                    sw      a5,0(s0)
   10b7c:       4501                    li      a0,0
   10b7e:       70a2                    ld      ra,40(sp)
   10b80:       7402                    ld      s0,32(sp)
   10b82:       64e2                    ld      s1,24(sp)
   10b84:       6942                    ld      s2,16(sp)
   10b86:       69a2                    ld      s3,8(sp)
   10b88:       6145                    addi    sp,sp,48
   10b8a:       8082                    ret
   10b8c:       37fd                    addiw   a5,a5,-1
   10b8e:       b7f5                    j       0x10b7a
   10b90:       0200c7b7                lui     a5,0x200c
   10b94:       ff87b703                ld      a4,-8(a5) # 0x200bff8
   10b98:       0200c6b7                lui     a3,0x200c
   10b9c:       3e970713                addi    a4,a4,1001
   10ba0:       ff86b783                ld      a5,-8(a3) # 0x200bff8
   10ba4:       fee7eee3                bltu    a5,a4,0x10ba0
   10ba8:       32000713                li      a4,800
   10bac:       31f9079b                addiw   a5,s2,799
   10bb0:       02e7d7bb                divuw   a5,a5,a4
   10bb4:       00080737                lui     a4,0x80
   10bb8:       c038                    sw      a4,64(s0)
   10bba:       4858                    lw      a4,20(s0)
   10bbc:       00176713                ori     a4,a4,1
   10bc0:       c858                    sw      a4,20(s0)
   10bc2:       00042823                sw      zero,16(s0)
   10bc6:       0007871b                sext.w  a4,a5
   10bca:       12071f63                bnez    a4,0x10d08
   10bce:       c018                    sw      a4,0(s0)
   10bd0:       4c1c                    lw      a5,24(s0)
   10bd2:       44a9                    li      s1,10
   10bd4:       0037e793                ori     a5,a5,3
   10bd8:       cc1c                    sw      a5,24(s0)
   10bda:       34fd                    addiw   s1,s1,-1
   10bdc:       0ff00593                li      a1,255
   10be0:       8522                    mv      a0,s0
   10be2:       e76ff0ef                jal     ra,0x10258
   10be6:       f8f5                    bnez    s1,0x10bda
   10be8:       4c1c                    lw      a5,24(s0)
   10bea:       09500693                li      a3,149
   10bee:       4601                    li      a2,0
   10bf0:       9bf1                    andi    a5,a5,-4
   10bf2:       cc1c                    sw      a5,24(s0)
   10bf4:       04000593                li      a1,64
   10bf8:       8522                    mv      a0,s0
   10bfa:       ec1ff0ef                jal     ra,0x10aba
   10bfe:       84aa                    mv      s1,a0
   10c00:       0ff00593                li      a1,255
   10c04:       8522                    mv      a0,s0
   10c06:       e52ff0ef                jal     ra,0x10258
   10c0a:       4c1c                    lw      a5,24(s0)
   10c0c:       4705                    li      a4,1
   10c0e:       4505                    li      a0,1
   10c10:       9bf1                    andi    a5,a5,-4
   10c12:       cc1c                    sw      a5,24(s0)
   10c14:       f6e495e3                bne     s1,a4,0x10b7e
   10c18:       08700693                li      a3,135
   10c1c:       1aa00613                li      a2,426
   10c20:       04800593                li      a1,72
   10c24:       8522                    mv      a0,s0
   10c26:       e95ff0ef                jal     ra,0x10aba
   10c2a:       84aa                    mv      s1,a0
   10c2c:       0ff00593                li      a1,255
   10c30:       8522                    mv      a0,s0
   10c32:       e26ff0ef                jal     ra,0x10258
   10c36:       0ff00593                li      a1,255
   10c3a:       8522                    mv      a0,s0
   10c3c:       e1cff0ef                jal     ra,0x10258
   10c40:       0ff00593                li      a1,255
   10c44:       8522                    mv      a0,s0
   10c46:       e12ff0ef                jal     ra,0x10258
   10c4a:       89aa                    mv      s3,a0
   10c4c:       0ff00593                li      a1,255
   10c50:       8522                    mv      a0,s0
   10c52:       e06ff0ef                jal     ra,0x10258
   10c56:       0005071b                sext.w  a4,a0
   10c5a:       f5670713                addi    a4,a4,-170 # 0x7ff56
   10c5e:       14fd                    addi    s1,s1,-1
   10c60:       00f9f793                andi    a5,s3,15
   10c64:       00e03733                snez    a4,a4
   10c68:       009034b3                snez    s1,s1
   10c6c:       17fd                    addi    a5,a5,-1
   10c6e:       00f037b3                snez    a5,a5
   10c72:       8cd9                    or      s1,s1,a4
   10c74:       0ff00593                li      a1,255
   10c78:       8522                    mv      a0,s0
   10c7a:       8cdd                    or      s1,s1,a5
   10c7c:       ddcff0ef                jal     ra,0x10258
   10c80:       4c1c                    lw      a5,24(s0)
   10c82:       4509                    li      a0,2
   10c84:       9bf1                    andi    a5,a5,-4
   10c86:       cc1c                    sw      a5,24(s0)
   10c88:       ee049be3                bnez    s1,0x10b7e
   10c8c:       4985                    li      s3,1
   10c8e:       06500693                li      a3,101
   10c92:       4601                    li      a2,0
   10c94:       07700593                li      a1,119
   10c98:       8522                    mv      a0,s0
   10c9a:       e21ff0ef                jal     ra,0x10aba
   10c9e:       0ff00593                li      a1,255
   10ca2:       8522                    mv      a0,s0
   10ca4:       db4ff0ef                jal     ra,0x10258
   10ca8:       4c1c                    lw      a5,24(s0)
   10caa:       07700693                li      a3,119
   10cae:       40000637                lui     a2,0x40000
   10cb2:       9bf1                    andi    a5,a5,-4
   10cb4:       cc1c                    sw      a5,24(s0)
   10cb6:       06900593                li      a1,105
   10cba:       8522                    mv      a0,s0
   10cbc:       dffff0ef                jal     ra,0x10aba
   10cc0:       0ff57493                andi    s1,a0,255
   10cc4:       0ff00593                li      a1,255
   10cc8:       8522                    mv      a0,s0
   10cca:       d8eff0ef                jal     ra,0x10258
   10cce:       4c1c                    lw      a5,24(s0)
   10cd0:       9bf1                    andi    a5,a5,-4
   10cd2:       cc1c                    sw      a5,24(s0)
   10cd4:       fb348de3                beq     s1,s3,0x10c8e
   10cd8:       450d                    li      a0,3
   10cda:       ea0492e3                bnez    s1,0x10b7e
   10cde:       46d5                    li      a3,21
   10ce0:       20000613                li      a2,512
   10ce4:       05000593                li      a1,80
   10ce8:       8522                    mv      a0,s0
   10cea:       dd1ff0ef                jal     ra,0x10aba
   10cee:       84aa                    mv      s1,a0
   10cf0:       0ff00593                li      a1,255
   10cf4:       8522                    mv      a0,s0
   10cf6:       d62ff0ef                jal     ra,0x10258
   10cfa:       4c1c                    lw      a5,24(s0)
   10cfc:       4515                    li      a0,5
   10cfe:       9bf1                    andi    a5,a5,-4
   10d00:       cc1c                    sw      a5,24(s0)
   10d02:       e60482e3                beqz    s1,0x10b66
   10d06:       bda5                    j       0x10b7e
   10d08:       fff7871b                addiw   a4,a5,-1
   10d0c:       b5c9                    j       0x10bce

// sd_copy
   10d0e:       715d                    addi    sp,sp,-80
   10d10:       f052                    sd      s4,32(sp)
   10d12:       e45e                    sd      s7,8(sp)
   10d14:       8a36                    mv      s4,a3
   10d16:       8bae                    mv      s7,a1
   10d18:       4685                    li      a3,1
   10d1a:       05200593                li      a1,82
   10d1e:       e0a2                    sd      s0,64(sp)
   10d20:       e486                    sd      ra,72(sp)
   10d22:       fc26                    sd      s1,56(sp)
   10d24:       f84a                    sd      s2,48(sp)
   10d26:       f44e                    sd      s3,40(sp)
   10d28:       ec56                    sd      s5,24(sp)
   10d2a:       e85a                    sd      s6,16(sp)
   10d2c:       842a                    mv      s0,a0
   10d2e:       d8dff0ef                jal     ra,0x10aba
   10d32:       e16d                    bnez    a0,0x10e14
   10d34:       6909                    lui     s2,0x2
   10d36:       8aaa                    mv      s5,a0
   10d38:       0fe00993                li      s3,254
   10d3c:       1901                    addi    s2,s2,-32
   10d3e:       0ff00593                li      a1,255
   10d42:       8522                    mv      a0,s0
   10d44:       d14ff0ef                jal     ra,0x10258
   10d48:       ff351be3                bne     a0,s3,0x10d3e
   10d4c:       200b8493                addi    s1,s7,512
   10d50:       4b01                    li      s6,0
   10d52:       0ff00593                li      a1,255
   10d56:       8522                    mv      a0,s0
   10d58:       d00ff0ef                jal     ra,0x10258
   10d5c:       008b571b                srliw   a4,s6,0x8
   10d60:       008b1793                slli    a5,s6,0x8
   10d64:       8fd9                    or      a5,a5,a4
   10d66:       8fa9                    xor     a5,a5,a0
   10d68:       03079b13                slli    s6,a5,0x30
   10d6c:       030b5b13                srli    s6,s6,0x30
   10d70:       004b579b                srliw   a5,s6,0x4
   10d74:       8bbd                    andi    a5,a5,15
   10d76:       0167c7b3                xor     a5,a5,s6
   10d7a:       00c79713                slli    a4,a5,0xc
   10d7e:       8fb9                    xor     a5,a5,a4
   10d80:       0107979b                slliw   a5,a5,0x10
   10d84:       4107d79b                sraiw   a5,a5,0x10
   10d88:       0107971b                slliw   a4,a5,0x10
   10d8c:       0107571b                srliw   a4,a4,0x10
   10d90:       0057171b                slliw   a4,a4,0x5
   10d94:       01277733                and     a4,a4,s2
   10d98:       8fb9                    xor     a5,a5,a4
   10d9a:       00ab8023                sb      a0,0(s7)
   10d9e:       03079b13                slli    s6,a5,0x30
   10da2:       0b85                    addi    s7,s7,1
   10da4:       030b5b13                srli    s6,s6,0x30
   10da8:       fa9b95e3                bne     s7,s1,0x10d52
   10dac:       0ff00593                li      a1,255
   10db0:       8522                    mv      a0,s0
   10db2:       ca6ff0ef                jal     ra,0x10258
   10db6:       0085149b                slliw   s1,a0,0x8
   10dba:       0ff00593                li      a1,255
   10dbe:       8522                    mv      a0,s0
   10dc0:       14c2                    slli    s1,s1,0x30
   10dc2:       90c1                    srli    s1,s1,0x30
   10dc4:       c94ff0ef                jal     ra,0x10258
   10dc8:       00a4e7b3                or      a5,s1,a0
   10dcc:       17c2                    slli    a5,a5,0x30
   10dce:       93c1                    srli    a5,a5,0x30
   10dd0:       05679063                bne     a5,s6,0x10e10
   10dd4:       1a7d                    addi    s4,s4,-1
   10dd6:       f74044e3                bgtz    s4,0x10d3e
   10dda:       4685                    li      a3,1
   10ddc:       4601                    li      a2,0
   10dde:       04c00593                li      a1,76
   10de2:       8522                    mv      a0,s0
   10de4:       cd7ff0ef                jal     ra,0x10aba
   10de8:       0ff00593                li      a1,255
   10dec:       8522                    mv      a0,s0
   10dee:       c6aff0ef                jal     ra,0x10258
   10df2:       4c1c                    lw      a5,24(s0)
   10df4:       9bf1                    andi    a5,a5,-4
   10df6:       cc1c                    sw      a5,24(s0)
   10df8:       60a6                    ld      ra,72(sp)
   10dfa:       6406                    ld      s0,64(sp)
   10dfc:       8556                    mv      a0,s5
   10dfe:       74e2                    ld      s1,56(sp)
   10e00:       7942                    ld      s2,48(sp)
   10e02:       79a2                    ld      s3,40(sp)
   10e04:       7a02                    ld      s4,32(sp)
   10e06:       6ae2                    ld      s5,24(sp)
   10e08:       6b42                    ld      s6,16(sp)
   10e0a:       6ba2                    ld      s7,8(sp)
   10e0c:       6161                    addi    sp,sp,80
   10e0e:       8082                    ret
   10e10:       4a89                    li      s5,2
   10e12:       b7e1                    j       0x10dda
   10e14:       0ff00593                li      a1,255
   10e18:       8522                    mv      a0,s0
   10e1a:       c3eff0ef                jal     ra,0x10258
   10e1e:       4c1c                    lw      a5,24(s0)
   10e20:       4a85                    li      s5,1
   10e22:       9bf1                    andi    a5,a5,-4
   10e24:       cc1c                    sw      a5,24(s0)
   10e26:       bfc9                    j       0x10df8
        ...
   10e80:       0dd0                    addi    a2,sp,724
   10e82:       edfe                    sd      t6,216(sp)
   10e84:       0000                    unimp
   10e86:       3628                    fld     fa0,104(a2)
   10e88:       0000                    unimp
   10e8a:       3800                    fld     fs0,48(s0)
   10e8c:       0000                    unimp
   10e8e:       8425                    srai    s0,s0,0x9
   10e90:       0000                    unimp
   10e92:       2800                    fld     fs0,16(s0)
   10e94:       0000                    unimp
   10e96:       1100                    addi    s0,sp,160
   10e98:       0000                    unimp
   10e9a:       1000                    addi    s0,sp,32
   10e9c:       0000                    unimp
   10e9e:       0000                    unimp
   10ea0:       0000                    unimp
   10ea2:       b202                    fsd     ft0,288(sp)
   10ea4:       0000                    unimp
   10ea6:       4c25                    li      s8,9
        ...
   10eb8:       0000                    unimp
   10eba:       0100                    addi    s0,sp,128
   10ebc:       0000                    unimp
   10ebe:       0000                    unimp
   10ec0:       0000                    unimp
   10ec2:       0300                    addi    s0,sp,384
   10ec4:       0000                    unimp
   10ec6:       0400                    addi    s0,sp,512
   10ec8:       0000                    unimp
   10eca:       0000                    unimp
   10ecc:       0000                    unimp
   10ece:       0200                    addi    s0,sp,256
   10ed0:       0000                    unimp
   10ed2:       0300                    addi    s0,sp,384
   10ed4:       0000                    unimp
   10ed6:       0400                    addi    s0,sp,512
   10ed8:       0000                    unimp
   10eda:       0f00                    addi    s0,sp,912
   10edc:       0000                    unimp
   10ede:       0200                    addi    s0,sp,256
   10ee0:       0000                    unimp
   10ee2:       0300                    addi    s0,sp,384
   10ee4:       0000                    unimp
   10ee6:       2b00                    fld     fs0,16(a4)
   10ee8:       0000                    unimp
   10eea:       1b00                    addi    s0,sp,432
   10eec:       69466953                0x69466953
   10ef0:       6576                    ld      a0,344(sp)
   10ef2:       462c                    lw      a1,72(a2)
   10ef4:       3755                    addiw   a4,a4,-11
   10ef6:       3034                    fld     fa3,96(s0)
   10ef8:       432d                    li      t1,11
   10efa:       3030                    fld     fa2,96(s0)
   10efc:       2d30                    fld     fa2,88(a0)
   10efe:       6564                    ld      s1,200(a0)
   10f00:       0076                    c.slli  zero,0x1d
   10f02:       7566                    ld      a0,120(sp)
   10f04:       2d303037                lui     zero,0x2d303
   10f08:       6564                    ld      s1,200(a0)
   10f0a:       0076                    c.slli  zero,0x1d
   10f0c:       69666973                csrrsi  s2,0x696,12
   10f10:       6576                    ld      a0,344(sp)
   10f12:       642d                    lui     s0,0xb
   10f14:       7665                    lui     a2,0xffff9
   10f16:       0000                    unimp
   10f18:       0000                    unimp
   10f1a:       0300                    addi    s0,sp,384
   10f1c:       0000                    unimp
   10f1e:       1200                    addi    s0,sp,288
   10f20:       0000                    unimp
   10f22:       2600                    fld     fs0,8(a2)
   10f24:       69466953                0x69466953
   10f28:       6576                    ld      a0,344(sp)
   10f2a:       462c                    lw      a1,72(a2)
   10f2c:       3755                    addiw   a4,a4,-11
   10f2e:       3034                    fld     fa3,96(s0)
   10f30:       432d                    li      t1,11
   10f32:       3030                    fld     fa2,96(s0)
   10f34:       0030                    addi    a2,sp,8
   10f36:       0000                    unimp
   10f38:       0000                    unimp
   10f3a:       0100                    addi    s0,sp,128
   10f3c:       6c61                    lui     s8,0x18
   10f3e:       6169                    addi    sp,sp,208
   10f40:       00736573                csrrsi  a0,0x7,6
   10f44:       0000                    unimp
   10f46:       0300                    addi    s0,sp,384
   10f48:       0000                    unimp
   10f4a:       1500                    addi    s0,sp,672
   10f4c:       0000                    unimp
   10f4e:       2c00                    fld     fs0,24(s0)
   10f50:       636f732f                0x636f732f
   10f54:       7265732f                0x7265732f
   10f58:       6169                    addi    sp,sp,208
   10f5a:       406c                    lw      a1,68(s0)
   10f5c:       3031                    0x3031
   10f5e:       3130                    fld     fa2,96(a0)
   10f60:       3030                    fld     fa2,96(s0)
   10f62:       3030                    fld     fa2,96(s0)
   10f64:       0000                    unimp
   10f66:       0000                    unimp
   10f68:       0000                    unimp
   10f6a:       0300                    addi    s0,sp,384
   10f6c:       0000                    unimp
   10f6e:       1500                    addi    s0,sp,672
   10f70:       0000                    unimp
   10f72:       3400                    fld     fs0,40(s0)
   10f74:       636f732f                0x636f732f
   10f78:       7265732f                0x7265732f
   10f7c:       6169                    addi    sp,sp,208
   10f7e:       406c                    lw      a1,68(s0)
   10f80:       3031                    0x3031
   10f82:       3130                    fld     fa2,96(a0)
   10f84:       3031                    0x3031
   10f86:       3030                    fld     fa2,96(s0)
   10f88:       0000                    unimp
   10f8a:       0000                    unimp
   10f8c:       0000                    unimp
   10f8e:       0200                    addi    s0,sp,256
   10f90:       0000                    unimp
   10f92:       0100                    addi    s0,sp,128
   10f94:       73757063                bgeu    a0,s7,0x116b4
   10f98:       0000                    unimp
   10f9a:       0000                    unimp
   10f9c:       0000                    unimp
   10f9e:       0300                    addi    s0,sp,384
   10fa0:       0000                    unimp
   10fa2:       0400                    addi    s0,sp,512
   10fa4:       0000                    unimp
   10fa6:       0000                    unimp
   10fa8:       0000                    unimp
   10faa:       0100                    addi    s0,sp,128
   10fac:       0000                    unimp
   10fae:       0300                    addi    s0,sp,384
   10fb0:       0000                    unimp
   10fb2:       0400                    addi    s0,sp,512
   10fb4:       0000                    unimp
   10fb6:       0f00                    addi    s0,sp,912
   10fb8:       0000                    unimp
   10fba:       0000                    unimp
   10fbc:       0000                    unimp
   10fbe:       0100                    addi    s0,sp,128
   10fc0:       40757063                bgeu    a0,t2,0x113c0
   10fc4:       0030                    addi    a2,sp,8
   10fc6:       0000                    unimp
   10fc8:       0000                    unimp
   10fca:       0300                    addi    s0,sp,384
   10fcc:       0000                    unimp
   10fce:       0400                    addi    s0,sp,512
   10fd0:       0000                    unimp
   10fd2:       3c00                    fld     fs0,56(s0)
   10fd4:       0000                    unimp
   10fd6:       0000                    unimp
   10fd8:       0000                    unimp
   10fda:       0300                    addi    s0,sp,384
   10fdc:       0000                    unimp
   10fde:       1500                    addi    s0,sp,672
   10fe0:       0000                    unimp
   10fe2:       1b00                    addi    s0,sp,432
   10fe4:       69666973                csrrsi  s2,0x696,12
   10fe8:       6576                    ld      a0,344(sp)
   10fea:       622c                    ld      a1,64(a2)
   10fec:       6c75                    lui     s8,0x1d
   10fee:       656c                    ld      a1,200(a0)
   10ff0:       3074                    fld     fa3,224(s0)
   10ff2:       7200                    ld      s0,32(a2)
   10ff4:       7369                    lui     t1,0xffffa
   10ff6:       00007663                bgeu    zero,zero,0x11002
   10ffa:       0000                    unimp
   10ffc:       0000                    unimp
   10ffe:       0300                    addi    s0,sp,384

