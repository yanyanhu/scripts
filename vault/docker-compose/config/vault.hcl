listener "tcp" {
    address     = "0.0.0.0:8200"
    tls_disable = 1
}

storage "postgresql" {
        connection_url = "postgres://$USER:$PASSWORD@localhost:5432/vault?sslmode=disable"
}

ui = true
