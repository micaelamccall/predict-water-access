p<-.libPaths() # assign location where you're installing packages
pkgs<-c('dplyr', 'tidyr', 'ggplot2', 'corrplot', 'psych', 'plotly', 'car') # required packages
`%notin%` <- Negate(`%in%`)

# Checking if we are using the same version of R
proj_version <- "R version 3.6.1 (2019-07-05)"
if (proj_version != version$version.string){
  print(paste("You have ", version$version.string, ". This project was created with R version 3.5.2 (2018-12-20). Some packages may not install or work properly"))
} else {
  print("You have the same version of R as was used in this project")
}

# Install and attach packages
for (i in 1:length(pkgs)){
  pkg<-pkgs[[i]]
  if (pkg %notin% rownames(installed.packages())){
    install.packages(pkg, p)
  }
  if (pkg %in% rownames(installed.packages()) & pkg %notin% loadedNamespaces()){
    library(pkg, character.only = T)
    print(paste("Attaching package:", pkg))
  }
  if (pkg %notin% rownames(installed.packages())){
    print(paste("Error installing ", pkg, ". Check Warnings."))
  }
}

