# A1 - Programação para Dispositivos Móveis I

Uma aplicação mobile desenvolvida em Flutter para facilitar a gestão de despesas automotivas, permitindo que motoristas acompanhem consumo de combustível, gastos recorrentes e desempenho individual de cada veículo cadastrado.

## Nome do App

**Opala** (porque bebe muito)

## Sobre o projeto

O aplicativo tem como objetivo facilitar a gestão de despesas automotivas, permitindo que motoristas acompanhem o consumo de combustível e os gastos recorrentes de um ou mais veículos (carros, motos, etc.).

O sistema oferece uma interface onde o usuário pode:

- Cadastrar sua frota pessoal;
- Registrar cada abastecimento (valor, litros, data, quilometragem e posto);
- Visualizar histórico de consumo e custos;
- Alternar entre veículos mantendo histórico e cálculos individualizados;
- Acompanhar médias de gasto e desempenho (km/l) por veículo.

## Requisitos Funcionais

### RF01 - Painel do Veículo

O aplicativo deve exibir os veículos do usuário em formato de cartões deslizáveis. Cada cartão apresenta nome/modelo e indicadores principais (gasto total no mês e média de quilometragem), centralizando a visão geral em um único lugar.

### RF02 - Histórico de Abastecimentos

Na mesma tela principal, logo abaixo do painel do veículo, o aplicativo deve exibir uma lista com o histórico de todos os abastecimentos realizados para o veículo selecionado no momento, detalhando posto, data e valor pago.

### RF03 - Cadastro de Dados

O sistema deve possuir formulários de entrada de dados para que o usuário possa:

- Registrar novos veículos.
- Registrar novos abastecimentos para determinado veículo.

## Stack Utilizada

<span>
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
<img src="https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white" alt="Material Design">
</span>

## Rodando Localmente 🖥️

Para executar o projeto em seu ambiente local, siga os passos abaixo.

### Pré-requisitos

- Flutter SDK (versão 3.11.0 ou superior)
- Dart SDK
- Android Studio ou VS Code
- Dispositivo Android/iOS ou emulador configurado

### Passos

1. Clone o repositório:

	```sh
	git clone https://github.com/Matheus-Nardi/opala.git
	```

2. Entre no diretório do repositório:

	```sh
	cd opala
	```

3. Instale as dependências:

	```sh
	flutter pub get
	```

4. Execute a aplicação:

	```sh
	flutter run
	```

5. A aplicação será iniciada no dispositivo ou emulador configurado.
