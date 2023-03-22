pacman::p_load(tidyverse,RSelenium,netstat,purrr)

# Cria um servidor para o "bot" navegar
rD <- rsDriver(browser=c("chrome"),chromever = "111.0.5563.64",verbose = T, port=free_port())
remDr <- rD$client

# Acessa o site/url
remDr$navigate("https://www.stats.govt.nz/large-datasets/csv-files-for-download/")


###### GENERALIZACAO DE BUSCA POR ELEMENTOS DO HTML via xpath
# // = Procura por todo ...... h3  cuja = [ classe @class = ""] / = com a tag a
######

data_files <- remDr$findElements(using = 'xpath', "//h3[@class='block-document__title']/a")

# função que retorna o nome dos arquivos
data_file_names <- lapply(data_files, function(x) {
  #getElementsText = extrais o nome\texto dos objetos de data_files
  # precisa fazer duas camadas de unlist ....unlist() e flatten_chr() pacote purr
  x$getElementText() %>% unlist()
}) %>% flatten_chr() %>% 
  # precisa remover o : do nome para não ter conflito
  str_remove_all("[:]")

# função que retorna os links dos arquivos
data_file_links <- lapply(data_files, function(x) {
  # getElementAttribute = retorna o atributo do elemento(no caso o link do download)
  x$getElementAttribute('href') %>% unlist()
}) %>% flatten_chr()

# loop para o download dos arquivos
for (i in 1:length(data_file_names)) {
  download.file(
    url = data_file_links[i],
    # Como existem arquivos .csv e .zip
    # foi extraido a extenssão dos arquivos e adicionado ao nome dos arquivos salvo.
    destfile = paste0(data_file_names[i], gsub(x = data_file_links[i], pattern = ".*[.]", replacement = "."))
  )
}
