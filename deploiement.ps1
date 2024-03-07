# Boucle pour créer 10 conteneurs
for ($i = 1; $i -le 10; $i++) {
    # Générer un nombre aléatoire entre 1 et 3 pour choisir l'image
    $imagerandom = Get-Random -Minimum 1 -Maximum 4

    # Construire le nom de l'image
    $nom_image = "image_attaquant$imagerandom"

    # Construire le nom du conteneur
    $nom_conteneur = "attaquant$i"

    # Exécuter la commande Docker pour créer le conteneur
    docker container run -d --name $nom_conteneur $nom_image
}
