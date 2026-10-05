# s3 site estático

# Criar o bucket
resource "aws_s3_bucket" "site" {
  bucket = "s3-gm-static-site-${random_string.random.result}"

  # Usar com cuidado que com force_destroy ele vai excluir o bucket com itens dentro
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "GM website"
  })
}

# Configurar acesso ao s3
resource "aws_s3_bucket_public_access_block" "site_public_access" {
  bucket = aws_s3_bucket.site.id

  # O ideal é deixar tudo true e fazer regras de liberação, mas como vou testar o site direto do s3 vou desabilitar temporariamente, após feito os testes habilito tudo como true
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Dar permissão nos objetos do s3 - Temporario - apenas para testar diretamente o site via s3
# Caso tenha feito teste antes deixando o s3 public pode executar os comandos abaixo para destruir a referencia do terraform
# terraform apply -target="aws_s3_bucket_policy.site_public_read" # para destruir
# terraform destroy -target="aws_s3_bucket_policy.site_public_read"
# terraform apply
# resource "aws_s3_bucket_policy" "site_public_read" {
#   bucket = aws_s3_bucket.site.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "PublicReadGetObject"
#         Effect    = "Allow"
#         Principal = "*"
#         Action = [
#           "s3:GetObject"
#         ]
#         Resource = [
#           "${aws_s3_bucket.site.arn}/*"
#         ]
#       }
#     ]
#   })

#   depends_on = [
#     aws_s3_bucket_public_access_block.site_public_access
#   ]
# }

# Dar permissão apenas para solicitações de acesso vindas do cloud front
resource "aws_s3_bucket_policy" "site_cloudfront_only" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.site.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cf_site.arn
          }
        }
      }
    ]
  })

  depends_on = [
    aws_cloudfront_distribution.cf_site
  ]
}

# Bloco para colocar que todos os dados inseridos no s3 o owner dos objetos vai ser o criador do bucket ou seja minha conta
resource "aws_s3_bucket_ownership_controls" "site_ownership_controls" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Encryptação no S3
resource "aws_s3_bucket_server_side_encryption_configuration" "site_encryption" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configuração de site estático no s3
resource "aws_s3_bucket_website_configuration" "site_website_conf" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# Bloco para subir as coisas no s3
resource "aws_s3_object" "static_website_files" {
  for_each = fileset("${path.module}/website", "**")

  bucket = aws_s3_bucket.site.id
  key    = each.value
  source = "${path.module}/website/${each.value}"
  #source       = "${path.module}/website/index.html"
  etag = filemd5("${path.module}/website/${each.value}")
  content_type = lookup({
    html = "text/html; charset=utf-8"
    css  = "text/css; charset=utf-8"
    svg  = "image/svg+xml"
  }, lower(regex("[^.]+$", each.value)), "application/octet-stream")

  # Dessa forma os arquivos vão ser upados na origim quando a replicação estiver configurada, com isso, ambos os s3 vão ter os mesmos arquivos
  depends_on = [ 
    aws_s3_bucket_replication_configuration.site_origin
   ]
}

#--------------------------------------------------------
# S3 Replication

# Nota: Se o S3 já tiver arquivos, via terraform não é possivel fazer um batch para copiar tudo o que esta na origem para o destino
# você pode fazer via portal ou via comandos para copiar de um bucket para o outro
# Ex:
# aws s3 sync s3://s3-origin s3://s3-destination --recursive --profile gusta # profile apenas se tiver mais de um configurado na maquina

# O bucket de origem vai ser o do site
# Habilitando versionamento ambos precisam ter habilitado
# Habilitando versionamento na origem
resource "aws_s3_bucket_versioning" "site_origin" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Criando o bucket de réplica
resource "aws_s3_bucket" "site_replica" {
  bucket = "replica-s3-gm-static-site-${random_string.random.result}"

  # Usar com cuidado que com force_destroy ele vai excluir o bucket com itens dentro
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "Replica GM website"
  })
}

# Habilitando versionamento na replica
resource "aws_s3_bucket_versioning" "site_replica" {
  bucket = aws_s3_bucket.site_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Réplica (mesmo configuração do s3 de origem)
resource "aws_s3_bucket_public_access_block" "site_replica" {
  bucket = aws_s3_bucket.site_replica.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site_replica" {
  bucket = aws_s3_bucket.site_replica.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configurando a replicação no s3 de origem
resource "aws_s3_bucket_replication_configuration" "site_origin" {
  bucket = aws_s3_bucket.site.id
  role   = aws_iam_role.s3_replication.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    # source_selection_criteria {
    #   # Opcional: replicar apenas objetos com determinada tag, etc. Caso aplique, nesse caso é tudo
    # }

    destination {
      bucket        = aws_s3_bucket.site_replica.arn
      storage_class = "STANDARD"
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.site_origin,
    aws_s3_bucket_versioning.site_replica
  ]
}