# ===== Section donnees =====  
.data
	nomFichier:	.asciiz		"grille.txt" 		# grille.txt est nom de fichier
	grille:		.space 81 				# Buffer pour stocker le contenu du fichier
	ligne:		.word -1       				# Ligne de la case vide actuelle
    	colonne:	.word -1      				# Colonne de la case vide actuelle
    	solutions: 	.space 100          			# Zone memoire pour 100 solutions
    	compteur_solutions: .word 0         			# Compteur de solutions trouvees
    	compteur: 	.word 0					# compteur qui servira pour avancer dans les solutions
	
# ===== Section code =====  
.text
# ----- Main ----- 
	main:
		jal	loadFile			# Ouvrez le fichier
    		jal	parseValues			# Lire le fichier et mettre dans l'adresse grille
    		jal	closeFile			# Fermez le ficher
    		la	$s0, grille			# Charger l'adresse de la grille dans $s0
    		jal	transformAsciiValues		# Transformer les valeurs de la grille en code ASCII 
    		jal	zeroToSpace			# Convertir 0 -> espace (ASCII 32)
    		jal	displaySudoku			# Afficher le tableau de sudoku comme tableau 9x9
    		j 	solve_sudoku			#r�soudre le sudoku

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
		li	$v0,	1			# Initialiser return valeur à 1	
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
    		sw 	$zero, 0($sp)      		# Effacer lesoctets
		sw 	$zero, 4($sp)      
		sw 	$zero, 8($sp)      
		sw 	$zero, 12($sp)     
		sw 	$zero, 16($sp)     
		sw 	$zero, 20($sp)    
		sw 	$zero, 24($sp)     
		sw 	$zero, 28($sp)     
		sw 	$zero, 32($sp)     		# Effacer octets
    		addi	$sp, $sp, 36			# Libérer l'espace alloué dans la pile (36 octets)
        	jr      $ra   	              		# Retourner à l'appelant
        	
####################################################################################################################################

# Fonction check_n_row
# Registres utilises : $t[0-3,6-7,9] $a0
	check_n_row:
    		#grille[0][ligne]
    		mul 	$t7, $a0, 9     		# Calculer l'index : ligne * 9
    		la	$t6, grille  	    		# Adresse de la grille que l'on incrementera pour comparer avec la premi�re donn�e en param�tre
    		add 	$t6, $t6, $t7			# Calculer l'adresse de la case de la premiere ligne de la colonne
    
    		li	$t7, 0           		# Chiffre actuel (de 0 à 8)
    	boucle_check_n_row:
    		li 	$t3, 8           		# Limite superieure
    		bgt 	$t7, $t3, Fin_boucle_check_n_row# Si chiffre($t7) > 8, retourner VRAI
    	
    		#deuxieme grille pour incrementer et comparer
    		mul 	$t1, $a0, 9     		# Calculer l'index : ligne * 9
    		la	$t0, grille      		# Adresse de la grille que l'on incrementera pour comparer avec la premiere donner en parametre
    		add 	$t0, $t0, $t1			# Calculer l'adresse de la case de la premiere ligne de la colonne
    	
    		lb	$t9, 0($t6)      		# Charger le caractere de la n-ieme colonne de la ligne dans $t9
    		li 	$t1, 0				# Chiffre colonne (de 0 à 8)
    	deuxieme_boucle_check_n_row:
    		bgt 	$t1, $t3, fin_deuxieme_boucle 	# Si chiffre($t1) > 8, saut vers fin_deuxieme_boucle
    		beq 	$t1, $t7, si_meme_indice	# Saut vers si_meme_indice si on est la meme case car on ne veut pas comparer une valeur a elle meme car sinon elle renvoie faux
    		
    		lb 	$t2, 0($t0)           		# Charger le caractere actuel dans $t8
    		beq 	$t2, 32, si_meme_indice		# Si $t8 == 32(un espace) alors a compte pas
    		beq 	$t2, $t9, mauvaise_ligne	# Si $t8(l'indice la colonne de la ligne actuel) est egal a $t9(l'indicie la colonne de la ligne a comparer) alors saut vers mauvaise_ligne:
   		addi 	$t0, $t0, 1			#incrementer la ligne
   		addi 	$t1, $t1, 1    			# Passer au chiffre suivant
   		j 	deuxieme_boucle_check_n_row	# reboucler
   	fin_deuxieme_boucle:
   		addi 	$t6, $t6, 1    			# Passer la colonne suivante
   		addi	$t7, $t7, 1    			# Passer au chiffre suivant
      		j boucle_check_n_row			# reboucler
   	Fin_boucle_check_n_row:
   		# chiffre valide, retourner VRAI   
   		li 	$v0, 1	
   		j 	boucle_check_rows
   	mauvaise_ligne:
		# chiffre invalide, retourner FAUX
     		li 	$v0, -1
    		jr 	$ra
   	si_meme_indice:
   		addi 	$t1, $t1, 1    			# Passer au chiffre suivant
   		addi 	$t0, $t0, 1			#incrementer la ligne
   		j	deuxieme_boucle_check_n_row	#reboucler

####################################################################################################################################

# Fonction check_n_square
#  Objectif : Vérifie la validité de la n-ième carré.
# Registres utilises : $t[0-4] $a[0-1]
	check_n_square:
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
        	j 	verifieEtAjouter        	# Sauter à l'étiquette verifieEtAjouter pour vérifier et ajouter la valeur

	continueApresAjouter:                		
        	addi	$t0, $t0, 1      		# Incrémenter $t0 pour passer au prochain indice dans le carré
        	addi	$t1, $t1, 1      		# Incrémenter l'adresse actuelle dans $t1
        	j 	boucleCheck_n_square		# Retourner à la boucle pour vérifier la prochaine valeur

	add6Condition:
    		addi	$t1, $t1, 6       		# Sauter 6 cases pour passer à la ligne suivante dans le carré 3x3
    		j 	continueCheck_n_square		# Retourner à la vérification de la prochaine case
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
    		li 	$v0, -1				# Charger -1 dans $v0 pour signaler qu'une erreur a été détectée (doublon)
	finCheck_n_square:
		sw 	$zero, 0($sp)      		# Effacer lesoctets
		sw 	$zero, 4($sp)      
		sw 	$zero, 8($sp)      
		sw 	$zero, 12($sp)     
		sw 	$zero, 16($sp)     
		sw 	$zero, 20($sp)    
		sw 	$zero, 24($sp)     
		sw 	$zero, 28($sp)     
		sw 	$zero, 32($sp)     		# Effacer octets
        	add	$sp, $sp, 36			# Libérer l'espace alloué dans la pile (36 octets)
        	jr      $ra   	              		# Retourner à l'appelant

####################################################################################################################################
		
# Fonction check_columns
# Objectif : Vérifie la validité de toutes les colonnes.
# Registres utilises : $t[0] $a[0]
	check_columns:
		li	$t0, 0				# Initialization de counter comme int i = 0;
		sub	$sp, $sp 8			# Réserver un espace dans la pile pour stocker $ra et parametre $t0
		li	$v0, 1			
	boucleCheck_columns:
		beq	$t0, 9 finCheck_columns		# Si counter == 9 on termine le boucle
		move 	$a0, $t0			# mettre t0 dans a0 comme argument pour l'appel de fonction
		sw      $ra, 0($sp)          		# Sauvegarder $ra
        	sw	$t0, 4($sp)	     		# Sauvegarder parametre $a0
        	jal	check_n_column			# appelle check_n_square
        	lw      $ra, 0($sp)        		# Récupérer $ra
        	lw	$t0, 4($sp)	   		# Récupérer $t0 
        	beq	$v0, -1, fauxColumns		# Si check_n_square retourner -1 pour l'un quelconque des carrés fin et afficher error 
        	addi	$t0, $t0, 1			# Increment le counter
        	j	boucleCheck_columns	
	fauxColumns:
		li	$v0, -1				# renvoyer -1 si quelque Column est pas bon
	finCheck_columns:
		addi	$sp, $sp, 8			# Libérer l'espace alloué dans la pile (8 octets)
		jr	$ra

####################################################################################################################################

# Fonction check_rows 
# Registres utilises : $t[3] $a[0]
	check_rows:
    		li 	$a0, 0				# index de la ligne
    		subi 	$a0, $a0, 1			# index - 1
    	boucle_check_rows:
    		li 	$t3, 8		           	# Limite superieure
    		addi 	$a0, $a0, 1			# incrementer index
    		bgt 	$a0, $t3, Fin_boucle_check_rows # Si chiffre($a0) > 8), retourner VRAI
    		j 	check_n_row			# saut vers check_n_row
    	Fin_boucle_check_rows:
    		# chiffre valide, retourner VRAI
    		li 	$v0, 1
    		jr 	$ra
	
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
		li 	$v0, -1				# renvoyer -1 si quelque square est pas bon
	finCheck_squares:
		add	$sp, $sp, 8			# Libérer l'espace alloué dans la pile (8 octets)
		jr	$ra
####################################################################################################################################		

# Fonction check_sudoku
# Objectif : vérifie si l'ensemble du Sudoku est valide..
# Registres utilises : $v0, $sp
	check_sudoku:
    		subi 	$sp, $sp, 4         		# Réserver 8 octets dans la pile
    		sw   	$ra, 0($sp)  		        # Sauvegarder l'adresse de retour
    
    		jal  	check_columns        		# Appeler la fonction pour vérifier les colonnes
    		bne  	$v0, 1, sudoku_invalid  	# Si $v0 != 1 (donc -1), le Sudoku est invalide
    		
    		jal  	check_rows           		# Appeler la fonction pour vérifier les lignes
    		bne  	$v0, 1, sudoku_invalid  	# Si $v0 != 1 (donc -1), le Sudoku est invalide
    		
    		jal  	check_squares        		# Appeler la fonction pour vérifier les sous-grilles
    		bne  	$v0, 1, sudoku_invalid  	# Si $v0 != 1 (donc -1), le Sudoku est invalide
    	
    		li   	$v0, 1               		# Mettre $v0 à 0 (Sudoku valide)
    		j    	sudoku_return        		# Aller à la fin de la fonction
	sudoku_invalid:
    		li   	$v0, -1             		# Mettre $v0 à -1 (Sudoku invalide)
	sudoku_return:
   		lw	$ra, 0($sp)          		# Restaurer l'adresse de retour
    		addi 	$sp, $sp, 4          		# Libérer l'espace dans la pile
    		jr   	$ra                  		# Retourner à l'appelant

####################################################################################################################################	                                               


# Fonction solve_sudoku
# Registres utilises : $t[0-9] $a[0,3] 
	solve_sudoku:
    		la	$t0, grille			# mettre dans $t0 la grille
    		li 	$t1, 0           		# $t1 servira d'index pour parcourir la chaine
    	boucle_solve_sudoku:				#Trouver la premiere case vide
    		lb 	$t2, 0($t0)           		# Charger le caractere actuel dans $t2
       		beqz	$t2, Si_pas_vide  		# Si le caractere est NULL ('\0'), aucune case vide trouvee
       	 	beq 	$t2, 32, Si_vide		# Si $t2(l'indice) est egal a 0(32 car espace) alors saut vers Si_pas_vide
            	addi 	$t0, $t0, 1    			# Avancer d'une position dans la chaine
            	addi 	$t1, $t1, 1   			# Incrementer l'index global
        	j 	boucle_solve_sudoku		# saut vers boucle_solve_sudoku pour la boucle
    	Si_pas_vide:
    		# Aucune case vide trouvee, afficher la grille comme solution
    		jal 	displayGrille
		jal 	addNewLine
		
    		# Retourner VRAI
    		li 	$v0, 1           		# Valeur TRUE (1)
    		j 	autres_solutions		# pour voir si le sudoku a d'autres solutions
    	Si_vide:
    		addi 	$s1, $s1, 1			# Incrementer $s1 qui servira a changer $a3(pour trouver plusieurs solutions au sudoku)
    		
    		# Calculer ligne et colonne
    		div 	$t4, $t1, 9     		# $t4 = ligne (index diviser par 9)
    		mflo 	$t4            			# Recuperer le quotient
    		rem 	$t5, $t1, 9     		# $t5 = colonne (index modulo 9)

    		sw 	$t4, ligne       		# Stocker ligne
    		sw 	$t5, colonne     		# Stocker colonne
    		
    		lw 	$t3, compteur			# compteur pour avancer dans les solutions
    		beq 	$t3, $s1, n_essai		# Si $t3 est egal a $s1, alors on essaye de mettre l'index a n+1
    	premier_essai:				
    		# Essayer chaque chiffre de 1 a 9
    		# Pour trouver la premiere solution
    		li 	$t8, 1           		# Chiffre actuel (de 1 a 9)
    		j 	essayer_chiffre		
    	n_essai:		
    		# Essayer chaque chiffre de n+1 a 9		
    		# Pour voir si il y a d'autres solutions au sudoku
    		la 	$t7, solutions          	# $t7 est la solution actuelle
    		lw 	$t3, compteur			# compteur pour avancer dans les solutions
    		add 	$t7, $t7, $t3			# Avancer dans les solutions
    		lb 	$t8, 0($t7)              	# chiffre actuelle
    		addi 	$t8, $t8, 1			# incrementer le chiifre actuelle
    		li 	$t3, 0				# decrementer
    		sw 	$t3, compteur			# Sauvegarder
    	essayer_chiffre:
    		li 	$t3, 9           		# Limite superieure
    		bgt 	$t8, $t3, booleen_Faux 		# Si chiffre > 9, retourner FAUX
    	
    		lw 	$t0, ligne       		# Charger la ligne de la case vide
    		lw 	$t1, colonne     		# Charger la colonne de la case vide

    		# Placer le chiffre dans grille[ligne][colonne]
    		mul 	$t4, $t0, 9     		# Calculer l'index : ligne * 9
    		add 	$t4, $t4, $t1   		# Ajouter la colonne
    		la 	$t5, grille      		# Adresse de la grille
    		add 	$t5, $t5, $t4   		# Calculer l'adresse de la case
   		sb 	$t8, 0($t5)      		# Placer le chiffre dans la grille

   	 	# V�rifier la validit� de la grille
    		jal 	check_sudoku    		# Appeler la fonction de validation
    		li 	$t7, 1        			# Charger TRUE
    		bne 	$v0, $t7, retirer_chiffre 	# Si invalide, retirer le chiffre
    		
    		# Pour trouver plusieurs solutions
    		beq 	$t8, 9, recursivite		# Si le chiffre actuel est 9 alors il n'y aura pas d'autres solutions
    		bne 	$a3, 0, recursivite		# Si $a3 est different de 0, alors la verification est deja faite
    		
    		lw 	$t9, compteur_solutions      	# Charger le compteur
    		addi 	$t9, $t9, 1            		# Incrementer
    		
    		la 	$t7, solutions           	# $t7 est la solution actuelle
    		add 	$t7, $t7, $t9            	# Avancer dans les solutions
    		sb 	$t8, 0($t7)              	# Copier la valeur actuelle dans les solutions
    		
    		sw 	$t9, compteur_solutions     	# Sauvegarder
	recursivite:
		
   		# Appel r�cursif � solve_sudoku
    		j 	solve_sudoku

    	retirer_chiffre:
	    	# R�tro-propagation : retirer le chiffre de la case
    		li 	$t9, 48          		# Placer un caractere vide ('0')
   		sb 	$t9, 0($t5)      		# Reinitialiser la case
   	 	# Essayer le chiffre suivant
    		addi 	$t8, $t8, 1    			# Passer au chiffre suivant
    		j 	essayer_chiffre        		# Reboucler
    
	booleen_Faux:
    		# Aucun chiffre valide, retourner FAUX
    		li 	$v0, -1
    		j 	autres_solutions 		# Pour voir si il y a d'autres solutions

####################################################################################################################################

# Autres fonctions que nous avons ajoute :


# ----- Fonction LoadFile -----
# Objectif : Ouvrir un fichier
# Registre utilise:  $a[0-1], $v0
	loadFile:
		la 	$a0, nomFichier			# Charger l'adresse de la fichier
    		li	$a1, 0				# 0 = lecture mode
    		li	$v0, 13				# Appel système pour ouvrir le fichier
    		syscall					# En gros cette fonction renvoie un descripteur de fichier dans $v0
 
# ----- Fonction ParseValuess -----
# Objectif :  extrait l'ensemble des valeurs du Sudoku à partir du fichier spécifié en paramètre. 
# Registre utilise:  $a[0-2], $v0, $t0
	parseValues:
    		move	$t0, $v0			# Déplacez le descripteur de fichier qui est dans $v0 vers $t0.
    		li	$v0, 14				# Appel système pour lire le fichier
    		move	$a0, $t0          		# Déplacez le descripteur de fichie vers $a0
    		la	$a1, grille        		# Charger l'adresse de grille, Ici la valuer sera socker 
    		li	$a2, 81           		# Nombre de bytes à lire
    		syscall

# ----- Fonction closeFile -----
# Objectif :  ferme un descripteur de fichier.
# Registre utilise:  $a0, $v0, $t0
    	closeFile: 
   		li	$v0, 16            		# Appel système pour fermez la fichier
    		move 	$a0, $t0          		# Déplacez le descripteur de fichie vers $a0
    		syscall
    		jr	$ra

# ----- Fonction zeroToSpace -----
# Objectif : convertit les 0 (cases vides) de votre grille en espace. 
# registre utilisé: $t[0 - 2]
	zeroToSpace:
		li	$t1, 0				# Compteur d'index pour la boucle
		add	$sp, $sp, -4			# Libérer de l'espace sur la pile
		sw      $ra, 0($sp)			# Enregistrer l'adresse de retour
	boucleZeroToSpace:
		bge	$t1, 81, endZeroToSpace		# Arrêtez-vous si nous avons vérifié les 81 éléments
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


############################################################################################################################
# ----- Fonction autres_solutions: -----   
# Objectif : Voir si le sudoku n'a pas d'autres solutions
# registre utlisé: $t[0]

	autres_solutions:	
		# Reinitialiser la grille pour tester d'autres valeurs
		jal	loadFile			# Ouvrez le fichier
    		jal	parseValues			# Lire le fichier et mettre dans l'adresse grille
    		jal	closeFile			# Fermez le ficher
    		la	$s0, grille			# Charger l'adresse de la grille dans $s0
    		jal	transformAsciiValues		# Transformer les valeurs de la grille en code ASCII 
    		jal	zeroToSpace			# Convertir 0 -> espace (ASCII 32)
    		
	trouver_solutions:
		lw 	$t0, compteur_solutions      	# Charger le compteur
		beq 	$t0, 0, fin_solutions		# si le compteur est a 0 alors il n'y a plus de solution
		
		addi 	$a3, $a3, 1			# Incrementer $a3 qui servira pour tester les nouvelles valeurs(on l'utilise dans solve_sudoku)
		li 	$t1, 0				# initialiser le compteur a 0(qui servira pour avancer dans les solutions)
		add 	$t1, $t1, $a3			# mettre le compteur a $a3
		sw 	$t1, compteur 			# Sauvegarder
		
		li 	$s1, 0				# reinitialiser $s1 a 0
		
		subi 	$t0, $t0, 1			# Decrementer le compteur
		sw 	$t0, compteur_solutions      	# Sauvegarder
		j 	solve_sudoku			# Tester le sudoku avec d'autres valeurs
	fin_solutions:
		j 	exit


############################################################################################################################

exit: 
    li $v0, 10
    syscall

################################################## Fin de la code ##################################################


