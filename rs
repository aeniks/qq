

rs() {
pp 'rec '
read -re "rec"
rsync -a --info=name1 ${inc[*]} ${recus}@${rec}:/$recpath 
}
