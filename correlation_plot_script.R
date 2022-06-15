## graficos para os coeficientes de correlacao gerados pela analise do pyRate ##


# coletando os parametros de entrada
myargs = commandArgs(trailingOnly=TRUE)
n = as.numeric(myargs[1])

# loop para as replcias
for (i in 1:n){
  
  # abrindo os resultados da analise de correlacao gerados pelo pyrate:
  corPy = read.table(
    file.path(
      'pyrate_mcmc_logs', 
      paste(
        'pbdb_data_', i, 'replicate_', i,'_Grj_se_est_co2_0_expSp_expEx_HP.log',
        sep=''
      )
    ),
    header=TRUE
  )
  
  
  # coeficiente de correlacao da variavel ambiental com a taxa de especiacao (Gl)
  CImarginGl = 1.96*sd(corPy$Gl)
  
  jpeg(file.path('pyrate_mcmc_logs', paste('Gl_', i, '.jpeg', sep = '')))
  my_hist = hist(
    corPy$Gl,
    breaks = 50,
    plot = FALSE
  )
  my_color = ifelse(
    my_hist$breaks > mean(corPy$Gl) + CImarginGl,
    rgb(0.8,0,0,0.5), 
    ifelse(
      my_hist$breaks < mean(corPy$Gl) - CImarginGl, 
      rgb(0.8,0,0,0.5), 
      rgb(0.2,0.2,0.2,0.2)
    )
  )
  plot(
    my_hist, 
    col = my_color, 
    border = FALSE, 
    main = 'Correlation coefficient for Gl', 
    xlab = 'Gl', 
    ylab = 'Frequency'
  )
  abline(v=0)
  dev.off()
  
  
  # coeficiente de correlacao da variavel ambiental com a taxa de extincao (Gm):
  CImarginGm = 1.96*sd(corPy$Gm)
  
  jpeg(file.path('pyrate_mcmc_logs', paste('Gm_', i, '.jpeg', sep = '')))
  my_hist = hist(
    corPy$Gm,
    breaks = 50,
    plot = FALSE
  )
  my_color = ifelse(
    my_hist$breaks > mean(corPy$Gm) + CImarginGm,
    rgb(0.8,0,0,0.5), 
    ifelse(
      my_hist$breaks < mean(corPy$Gm) - CImarginGm, 
      rgb(0.8,0,0,0.5), 
      rgb(0.2,0.2,0.2,0.2) 
    )
  )
  plot(
    my_hist, 
    col = my_color, 
    border = FALSE, 
    main = 'Correlation coefficient for Gm', 
    xlab = 'Gm', 
    ylab = 'Frequency'
  )
  abline(v=0)
  dev.off()

}
