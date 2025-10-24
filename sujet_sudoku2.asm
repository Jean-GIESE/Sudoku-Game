# ===== Section donnees =====  
.data
	grille: .asciiz "415638972362479185789215364926341758138756429574982631257164893843597216691823547"
	faux_square: .asciiz "Square est fausse"
	faux_colonne: .asciiz "Colonne est fauuse"
	faux_sudoku: .asciiz "Le sudoku est faux \n"
	ligne:  .word -1       # Ligne de la case vide actuelle
    	colonne: .word -1      # Colonne de la case vide actuelle

# ===== Section code =====  
.text
# ----- Main ----- 
   # jal check_n_row  
main:
    la 	$s0, grille					# Charger l'adresse de la grille dans $s0
    jal transformAsciiValues
    jal displayGrille
    jal addNewLine
    jal addNewLine
    jal zeroToSpace
    jal displaySudoku
#    jal check_squares
#    jal	check_columns
#    jal check_rows
    j solve_sudoku
#    j exit

# ----- Fonctions ----- 


# ----- Fonction addNewLine -----  
# objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
addNewLine:
    li      $v0, 11
    li      $a0, 10
    syscall
    jr $ra


####################################################################################################################################

# ----- Fonction displayGrille -----   
# Affiche la grille.
# Registres utilises : $v0, $a0, $t[1-2]
	displayGrille:  
    		la      $s0, grille
    		add     $sp, $sp, -4        		# Sauvegarde de la reference du dernier jump
    		sw      $ra, 0($sp)
    		li      $t1, 0
   	boucle_displayGrille:
       		bge     $t1, 81, end_displayGrille     	# Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
            	add     $t2, $s0, $t1           	# $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            	lb      $a0, ($t2)             		# load byte at $t2(adress) in $a0
            	li      $v0, 1                  	# code pour l'affichage d'un entier
            	syscall
            	add     $t1, $t1, 1             	# $t1 += 1;
        	j boucle_displayGrille
    	end_displayGrille:
        	lw      $ra, 0($sp)                 	# On recharge la reference 
        	add     $sp, $sp, 4                 	# du dernier jump
    		jr $ra
    
####################################################################################################################################

# ----- Fonction transformAsciiValues -----   
# Objectif : transforme la grille de ascii a integer
# Registres utilises : $t[0-3]
	transformAsciiValues:  
    		add     $sp, $sp, -4
    		sw      $ra, 0($sp)
    		la      $t3, grille
    		li      $t0, 0
    	boucle_transformAsciiValues:
        	bge     $t0, 81, end_transformAsciiValues
        	add     $t1, $t3, $t0
            	lb      $t2, ($t1)
            	sub     $t2, $t2, 48
           	sb      $t2, ($t1)
            	add     $t0, $t0, 1
        	j boucle_transformAsciiValues
    	end_transformAsciiValues:
    		lw      $ra, 0($sp)
    		add     $sp, $sp, 4
    		jr $ra

####################################################################################################################################

# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat dans : $v0
# Registres utilises : $a0
	getModulo: 
    		sub     $sp, $sp, 4
    		sw      $ra, 0($sp)
    boucle_getModulo:
        	blt     $a0, $a1, end_getModulo
            	sub     $a0, $a0, $a1
        	j boucle_getModulo
    end_getModulo:
    		move    $v0, $a0
    		lw      $ra, 0($sp)
    		add     $sp, $sp, 4
    		jr $ra

#################################################
#               A completer !                   #
#                                               #
# Nom et prenom binome 1 : GIESE Jean           #
# Nom et prenom binome 2 : NEZAMI Abdullah      #

####################################################################################################################################

# Fonction check_n_column
#  Objectif : vérifie la validité de la n-ième colonne.
# Registres utilises : $t[0-4] $a[0]
	check_n_column:
		sub	$sp, $sp, 36			# Réserver un espace dans la pile pour 9 entier
		li      $t0, 0                		# Initialiser t0 = 0, c'est counter pour le boucle
		li	$t1, 0				# Initialiser t1 = 0,
		li	$t2, 0
		add	$t1, $a0, $t1 			# Commence t1 par le permier indice de la colnne a0		
	boucleCheck_n_column:
		beq	$t0, 9, finCheck_n_column	# Si t0 == 9 donc arret
		beq	$t0, 0, premierrRow		# pour premier fois on ne veut pas ajouter 9 pour sauter la ligne
		addi	$t1, $t1, 9			# Calculer l'adresse dans la indice 9 pour sauter la ligne
		premierrRow:			
		add	$a0, $s0, $t1			# charger l'address actuelle de la grille
		lb	$t4, ($a0)			# recupère la value de la grille
		mul	$t2, $t4, 4			# calculating la address dans la pille pour stocker la valeur
		subi	$t2, $t2, 4			# calculating la offset pour la pille car $sp(pille) comence à 0
		add	$t2, $sp, $t2			# calculating la case memoire ou stocker
		lw	$t3, 0($t2)      		# Charger la valeur déjà existante à l'adresse calculée dans $t2
		beq	$t4, 32, continueCheck_n_column	# Si la case est vide (valeur 32 = espace), sauter à continueApresAjouter
    		beq	$t3, $t4, exitError		# Si la valeur existe déjà (doublon), sauter à exitError 			
		sw	$t4, 0($t2)      		# Charger la valeur déjà existante à l'adresse calculée dans $t1
      	continueCheck_n_column:
      		addi	$t0, $t0, 1
    		j	boucleCheck_n_column		# Continuer la vérification des prochaines cases
    	exitError:
    		li      $v0, -1
    	finCheck_n_column:
    		sw $zero, 0($sp)      # Effacer lesoctets
		sw $zero, 4($sp)      
		sw $zero, 8($sp)      
		sw $zero, 12($sp)     
		sw $zero, 16($sp)     
		sw $zero, 20($sp)    
		sw $zero, 24($sp)     
		sw $zero, 28($sp)     
		sw $zero, 32($sp)     # Effacer octets
    		addi	$sp, $sp, 36			# Libérer l'espace alloué dans la pile (36 octets)
        	jr      $ra   	              		# Retourner à l'appelant
        	
####################################################################################################################################

# Fonction check_n_row
# Registres utilises : $t[0,1,3,6-9] $a0
check_n_row:
    #grille[0][ligne]
    mul $t7, $a0, 9     # Calculer l'index : ligne * 9
    la $t6, grille      # Adresse de la grille que l'on incr�mentera pour comparer avec la premi�re donn�e en param�tre
    add $t6, $t6, $t7	# Calculer l�adresse de la case de la premi�re ligne de la colonne
    
    li $t7, 0           # Chiffre actuel (de 0 � 8)
    boucle_check_n_row:
    	li $t3, 8           # Limite sup�rieure
    	bgt $t7, $t3, Fin_boucle_check_n_row # Si chiffre($t7) > 8, retourner VRAI
    	
    	#deuxi�me grille pour incr�menter et comparer
    	mul $t1, $a0, 9     # Calculer l'index : ligne * 9
    	la $t0, grille      # Adresse de la grille que l'on incr�mentera pour comparer avec la premi�re donn�e en param�tre
    	add $t0, $t0, $t1	# Calculer l�adresse de la case de la premi�re ligne de la colonne
    	
    	lb $t9, 0($t6)      # Charger le caract�re de la n-i�me colonne de la ligne dans $t9
    	li $t1, 0	# Chiffre colonne (de 0 � 8)
    	deuxieme_boucle_check_n_row:
    		bgt $t1, $t3, fin_deuxieme_boucle # Si chiffre($t1) > 8, saut vers fin_deuxieme_boucle
    		beq $t1, $t7, si_meme_indice	# Saut vers si_meme_indice si on est � la m�me case car on ne veut pas comparer une valeur � elle m�me car sinon elle renvoie faux
    		
    		lb $t2, 0($t0)           # Charger le caract�re actuel dans $t8
    		beq $t2, 32, si_meme_indice	# Si $t8 == 32(un espace) alors �a compte pas
    		beq $t2, $t9, mauvaise_ligne	# Si $t8(l'indice � la colonne de la ligne actuel) est �gal � $t9(l'indicie � la colonne de la ligne � comparer) alors saut vers mauvaise_ligne:
   		addi $t0, $t0, 1	#incr�menter la ligne
   		addi $t1, $t1, 1    # Passer au chiffre suivant
   		j deuxieme_boucle_check_n_row	# reboucler
   	fin_deuxieme_boucle:
   	
   	addi $t6, $t6, 1    # Passer � la colonne suivante
   	addi $t7, $t7, 1    # Passer au chiffre suivant
      	j boucle_check_n_row	# reboucler
   Fin_boucle_check_n_row:
   # chiffre valide, retourner VRAI   
   li $v0, 1	
   j boucle_check_rows
   
   mauvaise_ligne:
	# chiffre invalide, retourner FAUX
     	li $v0, -1
    	jr $ra
    	
   si_meme_indice:
   	addi $t1, $t1, 1    # Passer au chiffre suivant
   	addi $t0, $t0, 1	#incr�menter la ligne
   	j deuxieme_boucle_check_n_row	#reboucler

####################################################################################################################################

# Fonction check_n_square
#  Objectif : Vérifie la validité de la n-ième carré.
# Registres utilises : $t[0-4] $a[0-1]
	check_n_square:
		#li	$a0, 8
		li      $t0, 3                		# Initialiser t0 = 3 pour la formule : 3 x (n % 3) + 27 x (n / 3)
        	li      $a1, 3                		# Charger le module dans le deuxième argument (modulo = 3)        	
        	sub     $sp, $sp, 8           		# Réserver un espace dans la pile pour stocker $ra et parametre $a0
        	sw      $ra, 0($sp)          		# Sauvegarder $ra
        	sw	$a0, 4($sp)	     		# Sauvegarder parametre $a0
        	
        	jal     getModulo          		# Appeler la fonction getModulo, il envoyer résultat dans v0
        	move	$t1, $v0	      		# $t1 = n % 3 

        	lw      $ra, 0($sp)        		# Récupérer $ra
        	lw	$a0, 4($sp)	   		# Récupérer $a0 
        	add     $sp, $sp, 8        		# Libérer l'espace dans la pile
        	mul     $t1, $t1, $t0      		# Calculer t1 = 3 x (n % 3)
        				
        	div 	$a0, $t0          		# Effectuer la division n / 3
    		mflo 	$t0				# Récupérer quotient
    		li	$a1, 27		   		# a1 = 27
    		mul 	$t0, $t0, $a1	      		# t0 = 27 * (n /3)
    		add	$t1, $t1, $t0			# t1 = 3 x (n % 3) + 27 x (n / 3)
    		
    		li	$t0, 0				# Initialiser compteur d'index pour la boucle
    		sub     $sp, $sp, 36           		# Réserver un espace dans la pile pour 9 entier
    		add     $t1, $s0, $t1			# Calculer l'adresse de premier case de petite square: grille[t1]
    		li	$v0,	1			# Initialiser return valeur à 1
	boucleCheck_n_square:
    		bge	$t0, 9, finCheck_n_square	# Arrêtez-vous si nous avons vérifié les 9 éléments
    		beq	$t0, 3, add6Condition		# Si $tO = 3, ça veut dire que on a déja vu 3 indice dans petite sqaure donc sauter ligne.
    		beq	$t0, 6, add6Condition		# Si $tO = 6, ça veut dire que on a déja vu 3 indice dans petite sqaure donc sauter ligne
    		
    	continueCheck_n_square:
    		lb	$t2, ($t1) 			# Charger l'octet à l'adresse actuelle
        	j verifieEtAjouter        		# Sauter à l'étiquette verifieEtAjouter pour vérifier et ajouter la valeur

	continueApresAjouter:                		
        	addi	$t0, $t0, 1      		# Incrémenter $t0 pour passer au prochain indice dans le carré
        	addi	$t1, $t1, 1      		# Incrémenter l'adresse actuelle dans $t1
        	j 	boucleCheck_n_square		# Retourner à la boucle pour vérifier la prochaine valeur

	add6Condition:
    		addi	$t1, $t1, 6       		# Sauter 6 cases pour passer à la ligne suivante dans le carré 3x3
    		j continueCheck_n_square		# Retourner à la vérification de la prochaine case

	verifieEtAjouter:			
    		mul	$t4, $t2, 4			# Calculer l'adresse dans la pile : $t4 = $sp + (valeur * 4)
    		subi	$t4, $t4, 4
    		add	$t4, $sp, $t4  			# Ajouter l'offset au pointeur de pile ($sp) pour obtenir l'adresse effective
		lw	$t3, 0($t4)      		# Charger la valeur déjà existante à l'adresse calculée dans $t3
    		beq	$t2, 32, continueApresAjouter	# Si la case est vide (valeur 32 = espace), sauter à continueApresAjouter
    		beq	$t3, $t2, exitAlreadyExisite	# Si la valeur existe déjà (doublon), sauter à exitAlreadyExisite
    		sw	$t2, 0($t4)			# Sinon, stocker la valeur actuelle dans la pile
    		j	continueApresAjouter		# Continuer la vérification des prochaines cases
	exitAlreadyExisite:
    		li $v0, -1				# Charger -1 dans $v0 pour signaler qu'une erreur a été détectée (doublon)
	finCheck_n_square:
		sw $zero, 0($sp)      # Effacer lesoctets
		sw $zero, 4($sp)      
		sw $zero, 8($sp)      
		sw $zero, 12($sp)     
		sw $zero, 16($sp)     
		sw $zero, 20($sp)    
		sw $zero, 24($sp)     
		sw $zero, 28($sp)     
		sw $zero, 32($sp)     # Effacer octets
        	add	$sp, $sp, 36			# Libérer l'espace alloué dans la pile (36 octets)
        	jr      $ra   	              		# Retourner à l'appelant

####################################################################################################################################
		
# Fonction check_columns
# Objectif : Vérifie la validité de toutes les colonnes.
# Registres utilises : $t[0] $a[0]
	check_columns:
		li	$t0, 0				# Initialization de counter comme int i = 0;
		sub	$sp, $sp 8			# Réserver un espace dans la pile pour stocker $ra et parametre $t0
		li	$v0, 0			
	boucleCheck_columns:
		beq	$t0, 9 finCheck_columns		# Si counter == 9 on termine le boucle
		move 	$a0, $t0			# mettre t0 dans a0 comme argument pour l'appel de fonction
		sw      $ra, 0($sp)          		# Sauvegarder $ra
        	sw	$t0, 4($sp)	     		# Sauvegarder parametre $a0
        	jal	check_n_column			# appelle check_n_column
        	lw      $ra, 0($sp)        		# Récupérer $ra
        	lw	$t0, 4($sp)	   		# Récupérer $t0 
        	
        	beq	$v0, -1, fauxColumns		# Si check_n_square retourner -1 pour l'un quelconque des carrés fin et afficher error 
        	addi	$t0, $t0, 1			# Increment le counter
        	j	boucleCheck_columns	
	fauxColumns:
		la	$a0, faux_colonne
		li	$v0, 4
		syscall
		li	$v0, -1				# renvoyer -1 si quelque Column est pas bon
	finCheck_columns:
		addi	$sp, $sp, 8			# Libérer l'espace alloué dans la pile (8 octets)
		jr	$ra

####################################################################################################################################

# Fonction check_rows 
# Registres utilises : $t[3] $a[0]
check_rows:
    li $a0, 0	# index de la ligne
    subi $a0, $a0, 1	# index - 1
    boucle_check_rows:
    	li $t3, 8           # Limite sup�rieure
    	addi $a0, $a0, 1	# incr�menter index
    	bgt $a0, $t3, Fin_boucle_check_rows # Si chiffre($a0) > 8), retourner VRAI
    	j check_n_row	#saut vers check_n_row
    Fin_boucle_check_rows:
    # chiffre valide, retourner VRAI
    li $v0, 1
    jr $ra

####################################################################################################################################
                                            
# Fonction check_squares
# Objectif : Vérifie la validité de tous les carrés.
# Registres utilises : $t[0] $a[0]
	check_squares:
		li	$t0, 0				# Initialization de counter comme int i = 0;
		sub	$sp, $sp 8			# Réserver un espace dans la pile pour stocker $ra et parametre $t0
		li	$v0, 0	
	boucleCheck_squares:
		beq	$t0, 9 finCheck_squares		# Si counter == 8 on termine le boucle
		move 	$a0, $t0			# mettre t0 dans a0 comme argument pour l'appel de fonction
		sw      $ra, 0($sp)          		# Sauvegarder $ra
        	sw	$t0, 4($sp)	     		# Sauvegarder parametre $a0
        	jal	check_n_square
        	lw      $ra, 0($sp)        		# Récupérer $ra
        	lw	$t0, 4($sp)	   		# Récupérer $t0 
        	
        	beq	$v0, -1 fauxSquare		# Si check_n_square retourner -1 pour l'un quelconque des carrés fin et afficher error 
        	addi	$t0, $t0, 1			# Increment le counter
        	j	boucleCheck_squares
	fauxSquare:
		la	$a0, faux_square
		li	$v0, 4
		syscall
		li 	$v0, -1				# renvoyer -1 si quelque square est pas bon
	finCheck_squares:
	add	$sp, $sp, 8				# Libérer l'espace alloué dans la pile (8 octets)
		jr	$ra

####################################################################################################################################		

# Fonction check_sudoku

####################################################################################################################################	                                               

# Fonction solve_sudoku
# Registres utilises : $t[0-8] $a[0]
solve_sudoku:
    la $t0, grille	# mettre dans $t0 la grille
    li $t1, 0           # $t1 servira d'index pour parcourir la cha�ne
    boucle_solve_sudoku:		#Trouver la premi�re case vide
    	lb $t2, 0($t0)           # Charger le caract�re actuel dans $t2
       	beqz $t2, Si_vide  # Si le caract�re est NULL ('\0'), aucune case vide trouv�e
        beq 	$t2, 32, Si_pas_vide	# Si $t2(l'indice) est �gal � 0(32 car espace) alors saut vers Si_pas_vide
            addi $t0, $t0, 1    	# Avancer d'une position dans la cha�ne
            addi $t1, $t1, 1    # Incr�menter l'index global
        j boucle_solve_sudoku		# saut vers boucle_solve_sudoku pour la boucle
    
    Si_vide:
    	# Aucune case vide trouv�e, afficher la grille comme solution
    	jal displayGrille

    	# Retourner VRAI
    	li $v0, 1           # Valeur TRUE (1)
    	j exit
    Si_pas_vide:
    
    
    # Calculer ligne et colonne
    div $t4, $t1, 9     # $t4 = ligne (index divis� par 9)
    mflo $t4            # R�cup�rer le quotient
    rem $t5, $t1, 9     # $t5 = colonne (index modulo 9)

    sw $t4, ligne       # Stocker ligne
    sw $t5, colonne     # Stocker colonne
    
    # Essayer chaque chiffre de 1 � 9
    li $t8, 1           # Chiffre actuel (de 1 � 9)
    essayer_chiffre:
    	li $t3, 9           # Limite sup�rieure
    	bgt $t8, $t3, booleen_Faux # Si chiffre > 9, retourner FAUX
    	
    	lw $t0, ligne       # Charger la ligne de la case vide
    	lw $t1, colonne     # Charger la colonne de la case vide

    	# Placer le chiffre dans grille[ligne][colonne]
    	mul $t4, $t0, 9     # Calculer l'index : ligne * 9
    	add $t4, $t4, $t1   # Ajouter la colonne
    	la $t5, grille      # Adresse de la grille
    	add $t5, $t5, $t4   # Calculer l'adresse de la case
   	sb $t8, 0($t5)      # Placer le chiffre dans la grille

   	 # V�rifier la validit� de la grille
    	jal check_rows    # Appeler la fonction de validation (� compl�ter)
    	li $t7, 1        # Charger TRUE
    	bne $v0, $t7, retirer_chiffre # Si invalide, retirer le chiffre

   	 # Appel r�cursif � solve_sudoku
    	jal solve_sudoku
    	li $t7, 1        # Charger TRUE
    	beq $v0, $t7, solve_finit # Si solve_sudoku retourne VRAI, Sudoku r�solu

    retirer_chiffre:
	    # R�tro-propagation : retirer le chiffre de la case
    	li $t9, 0          # Placer un caract�re vide ('0')
   	sb $t9, 0($t5)      # R�initialiser la case

   	 # Essayer le chiffre suivant
    	addi $t8, $t8, 1    # Passer au chiffre suivant
    	j essayer_chiffre         # Reboucler
    
booleen_Faux:
    # afficher "Le sudoku est faux"
    la $a0, faux_sudoku	# mettre la chaine faux_sudoku dans $a0
    li $v0, 4	# Appel syst�me pour afficher une cha�ne
    syscall

    # Aucune valeur trouv�e, afficher la grille pour voir le probl�me
    jal displayGrille
    
    # Aucun chiffre valide, retourner FAUX
    li $v0, -1
    j exit


solve_finit:
    # R�solution termin�e, retourner VRAI
    lw $v0, 1
    j exit

####################################################################################################################################

# Autres fonctions que nous avons ajoute :

# ----- Fonction zeroToSpace -----
# Objectif : convertit les 0 (cases vides) de votre grille en espace. 
# registre utilisé: $t[0 - 2]
	zeroToSpace:
		li	$t1, 0				# Compteur d'index pour la boucle
		add	$sp, $sp, -4			# Lib�rer de l'espace sur la pile
		sw      $ra, 0($sp)			# Enregistrer l'adresse de retour
	boucleZeroToSpace:
		bge	$t1, 81, endZeroToSpace		# Arr�tez-vous si nous avons vérifié les 81 éléments
		add     $t2, $s0, $t1			# Calculer l'adresse de grille[t1]
		lb	$a0, ($t2) 			# Charger l'octet à l'adresse actuelle
		beq 	$a0, 0, transform 		# Si le caractère est '0', passez à la transformation
		addi	$t1, $t1, 1			# Incrémenter l'index
		j	boucleZeroToSpace		# Sautez pour continuer la boucle
	transform:
		li 	$a0, 32				# Remplacez '0' par un espace ASCII (32)
		sb 	$a0, ($t2) 			# Rangez le caractère dans la grille
		j	boucleZeroToSpace		# Sautez pour continuer la boucle
	endZeroToSpace:
		lw 	$ra, 0($sp)			# Restaure l'adresse de retour
		add 	$sp, $sp, 4			# Ajuste le pointeur de pile
		jr 	$ra 				# Retourne à l'appelant
 
####################################################################################################################################
                                                                                                                       
# ----- Fonction displaySudoku -----   
# Objectif : Affiche la Sudoku
# registre utlisé: $t[0-3]
	displaySudoku:
    		li	$t1, 0				# Compteur d'index pour la boucle
		add	$sp, $sp, -4			# Libérer de l'espace sur la pile
  	  	sw      $ra, 0($sp)			# Enregistrer l'adresse de retour
	boucleDisplaySudoku:
		bge	$t1, 81, endDisplaySudoku	# Quitter si les 81 éléments ont été traités
		add	$t2, $s0, $t1			# Calculer l'adresse de grille[t1]
		lb	$a0, ($t2)			# Charger l'octet actuel dans $a0
    		li      $t3, 32				# charger 32 pour vérification
   		beq     $a0, $t3, displaySpace		# Si on est sur 32  ajouter une espace
    		li      $v0, 1                     	# Sinon: Syscall code for printing an integer
    		syscall
   		j       checkNewline               	# Verifu si on doit  ajouter une ligne de retour ou non
	displaySpace:
 	  	li      $v0, 11                   	# Syscall code 
  	  	li      $a0, 32                    	# ASCII space
  	 	syscall
  	 	j       checkNewline            	# sauter ver le checkNewLine verification fucniton
	checkNewline:
  	  	addi    $t1, $t1, 1                	# incrementation de indice
  	  	move    $a0, $t1                   	# Move $t1 ver le $a0 pour le getModulo
  	  	li      $a1, 9                  	# charger 9 pour module dans deuxieme argument 
  	  	jal     getModulo
  	  	beq     $v0, 0, addNewLine		# si $v0 (retour value de mod fonction) est 0, ajouter nouveux ligne
	  	j       boucleDisplaySudoku
	endDisplaySudoku:
		lw 	$ra, 0($sp)			# Restaure l'adresse de retour
		add 	$sp, $sp, 4			# Ajuste le pointeur de pile
		jr 	$ra 				# Retourne à l'appelant

####################################################################################################################################

exit: 
    li $v0, 10
    syscall

################################################## Fin de la code ##################################################



