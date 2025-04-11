.text

main:
	lw	$a0, 0($a1)
	lb	$a0, 0($a0)
	addi	$a0, $a0, -0x30
	jal	hash_fn
	add	$s0, $v0, $0
	lui	$t0, 0x1001
	sw	$s0, 0($t0)
	addi	$v0, $0, 10
	syscall
	
hash_fn:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	add	$s2, $a0, $0
	addi	$s1, $0, 0x29
	#first byte
	srl	$t0, $s2, 24
	xor	$t0, $t0, $s1
	add	$a0, $t0, $0
	jal	function
	andi	$s1, $v0, 0xFF		
	#sb
	sll	$t0, $s2, 8
	srl	$t0, $t0, 24
	xor	$t0, $t0, $s1
	add	$a0, $t0, $0
	jal	function
	andi	$s1, $v0, 0xFF
	#tb
	sll	$t0, $s2, 16
	srl	$t0, $t0, 24
	xor	$t0, $t0, $s1
	add	$a0, $t0, $0
	jal	function
	andi	$s1, $v0, 0xFF
	#fb
	sll	$t0, $s2, 24
	srl	$t0, $t0, 24
	xor	$t0, $t0, $s1
	add	$a0, $t0, $0
	jal	function
	andi	$v0, $v0, 0xFF
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra	
function:
						#t0 ==> c
						#a0 ==>x
						#t1 is counter ==> i
						#t2 is x power 2 (w)
						#t3 is x power 3 (z)
						#t4 is 1 if x is negtive
						#t5 is -z (- x power of 3)
			add $t0,$a0,$0  	# c=x
			add $t2,$0,$0  		# w=0
			add $t3,$0,$0  		# z=0
			slti $t4,$a0,0 		#set if x less than one t4 will be equal 1
			beq $t4,$0,not_neg 	#if(x is negtave==> c=-x)
			sub $t0,$0,$a0     	#c=-x
	not_neg:	addi $t1,$0,0  		# i=1
	f_power2: 	beq $t1,$t0,L1  	#if(i==x) if true go to L1  (for loob) ==> for(int i=0;i<=c;i++) {w=w+c; }
			add $t2 , $t0,$t2  	#w=w+c
			andi $t2, $t2, 0xFF
			addi $t1,$t1,1   	#i=i+1
			j f_power2   		#jump to if condtion to check
	L1:     	addi $t1,$0,0   	# i=1
	       		add $t3,$0,$0	  	# z=0
	s_power3:   	beq $t1,$t0,L2 		#if(i==w) if true go to L2 for loob) ==> for(int i=1;i<=c;i++) {z=z+c; }
			add $t3 , $t2,$t3   	#z=z+w
			andi $t3, $t3, 0xFF
			add $t1,$t1,1  		#i=i+1
			j s_power3 		#jump to if condtion to check
	L2:		beq $t4,$0,L3 		#if(x is negtave==> z=-z)
			sub $t5,$0,$t3    	#m=-z
	L3:					
						#now: t6=177* z(x^3)
			addi $t6,$0,0
			addi $t1,$0,0		#i=0
			addi $s6,$0,177
	f_mul:		beq  $t1,$s6,L4        #if(i==z) if true go to L3 for loob) ==> for(int i=0;i<=z;i++) {t6=t6+177; }
			add $t6,$t6,$t3	
			andi $t6, $t6, 0xFF
			addi $t1,$t1,1         #t1=t1+1
			j f_mul
	L4:		beq $t4,$0,L5 		#if(x is negtave==> z=-z)
			sub $t6,$0,$t6    	#t6=-t6 if x neg
	L5:		sub $t6,$0,$t6		#from equation t6=-t6
						#now: t7=12* z(x^2)
			addi $t7,$0,0
			addi $t1,$0,0		#i=0
			addi $t8,$0,12
	s_mul:		beq  $t1,$t8,L6        #if(i==z) if true go to L3 for loob) ==> for(int i=0;i<=z;i++) {t6=t6+177; }
			add $t7,$t7,$t2		#t7=t7+x^2
			andi $t7, $t7, 0xFF
			addi $t1,$t1,1         #t1=t1+1
			j s_mul
	L6:		
			addi $t9,$0,0
			addi $t1,$0,0		
	T_mul:		beq  $t1,$t0,L7        
			addi $t9,$t9,54		
			andi $t9, $t9, 0xFF
			addi $t1,$t1,1         #t1=t1+1
			j T_mul
	L7:		beq $t4,$0,L8 		
			sub $t9,$0,$t9    	
	L8:		add $v0,$0,$0
			add $v0,$v0,$t6
			add $v0,$v0,$t7
			add $v0,$v0,$t9
			addi $v0,$v0,86
			jr $ra
