# Para as duas regiões, não precisa de dois providers: um único provider google consegue criar 
# recursos em regiões diferentes, é apenas para deixar como padrão que é colocado aqui
provider "google" {
  region = var.region_videos

  #Colocando no default todo o recurso vai obter essas tags
  default_labels = {
    project     = "multiregion-weblab-galb-2-managage-instancegroups"
    environment = "dv"
    managed_by  = "terraform"
    owner       = "gustavo"
  }
}