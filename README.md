# BlevVision

Aplicativo Flutter para descobrir filmes e series, organizar watchlist, agenda e progresso.

## Requisitos

- Flutter instalado
- Firebase configurado para o projeto

## Configuracao local

### 1. Dependencias

```bash
flutter pub get
```

### 2. Firebase Android

O projeto usa `android/app/google-services.json` versionado no repositório.

Se voce precisar trocar de projeto Firebase, substitua esse arquivo pelo da sua configuracao.

### 3. Assinatura Android

Copie o arquivo de exemplo e preencha com os dados reais do certificado:

```bash
copy android\\app\\keystore.properties.example android\\app\\keystore.properties
```

## Rodando o projeto

```bash
flutter run
```

## Observacoes

- `android/app/google-services.json` esta incluido no repositório atual.
- `android/app/keystore.properties` nao fica no Git para evitar expor credenciais de assinatura.
