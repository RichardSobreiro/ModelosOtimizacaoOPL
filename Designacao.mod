int M = ...;
int qPontosCarga = ...;
int qViagens = ...;

// Conjuntos
range P = 1..qPontosCarga; // Conjunto dos pontos de carga
range V = 1..qViagens; // Quantidade de viagens a serem alocadas para pontos de carga

// Parametros
float c[V][P] = ...; // Custo de atendimento da viagem v pelo ponto de carga p (Custo dos insumos + Custo rodoviário + Custo de pessoal)
int qvMax[P] = ...; // Quantidade de viagens que cada ponto de carga p pode atender por dia
float cuve[P] = ...; // 

// Variáveis de decisão
dvar boolean x[V][P];
dvar int qve[P];

// Modelo
minimize sum(v in V, p in P)((x[v][p] * c[v][p]) + (cuve[p] * qve[p]));

subject to{
	TodaViagemDeveSerAlocadaParaUmPontoDeCarga:
	forall(v in V){
		sum(p in P)(x[v][p]) == 1;	
	}
	
	SeMaisViagensQueACapacidadeDoPontoCargaSaoAtendidasCustoDeveSerPago:
	forall(p in P){
		qve[p] >= qvMax[p] - sum(v in V)(x[v][p]);
	}
	
	NaoNegatividade:
	forall(p in P){
		qve[p] >= 0;
	}
}
