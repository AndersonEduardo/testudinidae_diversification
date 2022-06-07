## Carregando e configurando dados ##

# carregando recursos
source("PyRate/pyrate_utilities.r")

# caregando arquivo com a lista das especies atuais
extant_sps = read.csv(
  "extant_sps.csv",
  header = FALSE,
  stringsAsFactors = FALSE
)

# pequeno ajuste, para tranformar "coluna" em "linha"
extant_sps = as.vector(extant_sps[,1])

# montando o arquivo de input do PyRate
extract.ages.pbdb(
  file = "pbdb_data.csv",
  extant_species = extant_sps,
  replicates = 10  # vamos rodar a analise com 10 replicas (pois algumas coisas sao estocasticas, no algoritmo)
)

# esse script deve gerar os seguintes arquivos no diretorio de trabalho:
# pbdb_data_SpeciesList.txt
# pbdb_data_PyRate.py
