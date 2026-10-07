# Dessa forma que você usa mais de 1 regiao da aws no terraform e para refernciar no recurso
# usa provider e o nome do alias ex. provider = bastion
provider "aws" {
  alias  = "app"       # Não precisa, a regra é: provider sem alias é o principal, considerado como default, quando for usar outro você usa  provider = aws.bastion
  region = "us-east-1" # N. Virginia

}

provider "aws" {
  alias  = "bastion" # Oregon. Quando for criar coisas aqui usar  provider = aws.bastion
  region = "us-west-2"

}