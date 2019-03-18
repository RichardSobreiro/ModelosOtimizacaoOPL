int M = ...;
int qPontosCarga = ...;
int qViagens = ...;

// Conjuntos
range P = 1..qPontosCarga; // Conjunto dos pontos de carga
range V = 1..qViagens; // Quantidade de viagens a serem alocadas para pontos de carga

// Parametros
float c[V][P] = ...; // Custo de atendimento da viagem v pelo ponto de carga p
int qvc[P] = ...; // Quantidade de viagens que cada ponto de carga p pode atender por dia
float cuve[P] = ...;

// Variáveis de decisão
dvar boolean x[V][P];
dvar float ce[P];
dvar int qve[P];
dvar boolean y;

// Modelo
minimize sum(v in V, p in P)((x[v][p] * c[v][p]) + ce[p]);

subject to{
	TodaViagemDeveSerAlocadaParaUmPontoDeCarga:
	forall(v in V){
		sum(p in P)(x[v][p]) == 1;	
	}
	
	SeMaisViagensQueACapacidadeDoPontoCargaSaoAtendidasCustoDeveSerPago:
	forall(p in P){
		//sum(v in V)(x[v][p]) - qvc[p] > 0; => ce[p] >= (//sum(v in V)(x[v][p]) - qvc[p]) * cuve[p];
		// sum(v in V)(x[v][p]) - qvc[p] > 0;
		// ce[p] - ((//sum(v in V)(x[v][p]) - qvc[p]) * cuve[p]) >= 0;
		-ce[p] + ((sum(v in V)(x[v][p]) - qvc[p]) * cuve[p]) <= M * y;
		sum(v in V)(x[v][p]) - qvc[p] <= M * (1 - y);
	}
}
 
