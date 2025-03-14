	IFNE WTCFEAT

rom_time
rot_c    fcb     $20     0 century
rot_y    fcb     $24     1 year
rot_o    fcb     $10     2 month
rot_d    fcb     $03     3 date
rot_h    fcb     $17     4 hour
rot_m    fcb     $55     5 minute
rot_s    fcb     0       6 second
rot_cs   fcb     0       7


* Read one byte from an internal's RTC register whose offset is in A upon
* routine entry. The register contents is returned in B.
* No other register is altered. FIRQ is temporarily disabled.
* Can be called from base or interrupt level.
WTREGRD	

;;;
;;; Get ISO 8601 time stamp from RTC and store at X
;;;
rtc_get_time
    pshs    x,a,b
    ldx #ram_time
rtc_get_time_loop
;;; Loop until two identical time stamps have been read
	bsr	rtc_get_time_sample
	tstb
	bne	rtc_get_time_loop
	clra
	ldb     1,x
	pshu    d
	ldb     2,x
	pshu    d
	ldb     3,x
	pshu    d
	ldb     4,x
	pshu    d
	ldb     5,x
	pshu    d
	ldb     6,x
	pshu    d
    puls    x,a,b,pc

rtc_get_time_sample
	clrb            ; Cant single step clrb
;        ldb     #0
;;; Read SECONDS
	pshs    x
	ldx	#rtc_reg_s1
	bsr	rtc_read_8bit
	puls    x
	cmpa	6,x
	beq	*+3
	incb
	sta	6,x
;	pshu    d
;;; Read MINUTES
	pshs    x
	ldx	#rtc_reg_mi1
	bsr	rtc_read_8bit
	puls    x
	anda	#$7f
	cmpa	5,x
	beq	*+3
	incb
	sta	5,x
;        pshu    d
;;; Read HOURS
	pshs    x
	ldx	#rtc_reg_h1
	bsr	rtc_read_8bit
	puls    x
	anda	#$3f
	cmpa	4,x
	beq	*+3
	incb
	sta	4,x
;        pshu    d
;;; Read DAY
	pshs    x
	ldx	#rtc_reg_d1
	bsr	rtc_read_8bit
	puls    x
	anda	#$3f
	cmpa	3,x
	beq	*+3
	incb
	sta	3,x
;        pshu    d
;;; Read MONTH
	pshs    x
	ldx	#rtc_reg_mo1
	bsr	rtc_read_8bit
	puls    x
	anda	#$1f
	cmpa	2,x
	beq	*+3
	incb
	sta	2,x
;        pshu    d
;;; Read YEAR
	pshs    x
	ldx	#rtc_reg_y1
	bsr	rtc_read_8bit
	puls    x
	cmpa	1,x
	beq	*+3
	incb
	sta	1,x
;        pshu    d
;;; Read CENTURY
;	lda	ram_time+0
;	sta	0,x
	rts
	
;;; Helper funtion to assemble two RTC nibs to one byte
rtc_read_8bit
	pshs    b
	lda	1,x
	asla
	asla
	asla
	asla
	ldb	0,x
	andb	#$0f
    pshs    b       ; ABA
    adda    ,S+     ; ABA
	puls    b,pc



* Write one byte to an internal's RTC register whose offset is in A upon
* routine entry. The register byte output value is in B upon entry.
* FIRQ is temporarily masked. All regs contents are preserved.
* Can be called from base or interrupt level.
WTREGWR	

;;;
;;; Set RTC to ISO 8601 time stamp stored at X
;;;
rtc_set_time
    pshs    a,b,x
    leax    rom_time,pcr
;;; Stop RTC
	lda	#$07
	sta	rtc_reg_cf
	lda	#$04            ; OUTPUT 1 SECOND PULSE ON STD.P
	sta	rtc_reg_ce
	clra                    ; CANT SINGLE STEP CLRA
;        lda     #0
	sta	rtc_reg_cd
;;; Set CENTURY
;	lda	0,x
;	sta	ram_time+0
;;; Set YEAR
	lda	1,x
	pshs    x
	ldx	#rtc_reg_y1
	bsr	rtc_write_8bit
	puls    x
;;; Set MONTH
	lda	2,x
	pshs    x
	ldx	#rtc_reg_mo1
	bsr	rtc_write_8bit
	puls    x
;;; Set DAY
	lda	3,x
	pshs    x
	ldx	#rtc_reg_d1
	bsr	rtc_write_8bit
	puls    x
;;; Set HOURS
	lda	4,x
	pshs    x
	ldx	#rtc_reg_h1
	bsr	rtc_write_8bit
	puls    x
;;; Set MINUTES
	lda	5,x
	pshs    x
	ldx	#rtc_reg_mi1
	bsr	rtc_write_8bit
	puls    x
;;; Set SECONDS
	lda	6,x
	pshs    x
	ldx	#rtc_reg_s1
	bsr	rtc_write_8bit
	puls    x
;;; Start RTC
	lda	#$04
	sta	rtc_reg_cf
	puls    a,b,x,pc
	
;;; Helper funtion to assemble two RTC nibs to one byte
rtc_write_8bit
	pshs    b
    tfr     a,b
	lsra
	lsra
	lsra
	lsra
	sta	1,x
	andb	#$0f
	stb	0,x
	puls    b,pc

	ENDC			WTCFEAT

