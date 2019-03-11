int M = ...;

int qC = ...;
int qP = ...;
int qB = ...;
int qVg = ...;
// ----------------------------------------------------------------------------------------------------------------------
range rC = 1..qC;
range rP = 1..qP;
range V = 1..(qC + qP);
range Vg = 1..(qVg);
range K = 1..qB;
range T = 1..1440;
// ----------------------------------------------------------------------------------------------------------------------
// Parametros
float cr[V][V] = ...; // Custo rodoviario
float cac[V][rP] = ...; // Custo de atendimento do client j pelo ponto de carga p
int ti[V][V] = ...; // Tempo trajeto ida
int tv[V][V] = ...; // Tempo trajeto volta
int tp[rP] = ...; // Tempo de pesagem em cada ponto de carga
int td[V] = ...;
int hc[rC][Vg] = ...; // Hora de chega para cada viagem do cliente
float vc[rC][Vg] = ...; // Volume de material solicitado pelo cliente em cada viagem 
int qv[V] = ...; // Quantidade de viagens para cada cliente
int kp[rP] = ...; // Quantidade veiculos disponiveis por central
// ----------------------------------------------------------------------------------------------------------------------
// Variaveis decisao
dvar boolean x[V][V][K][rP]; // Se a rota de i para j é percorrida pelo veiculo k
dvar int hp[K][V][Vg]; // Hora de pesagem da viagem v para atendimento do cliente c para a viagem v
dvar int hsac[K][rP][V][Vg]; // Hora de saida do veiculo k para atendimento do cliente c para a viagem v
dvar int hiac[K][rP][V][Vg]; // Hora de início do atendimento do cliente c pelo veiculo k para a viagem v
dvar int hfac[K][rP][V][Vg]; // Hora de final do atendimento do cliente c pelo veiculo k para a viagem v
dvar int hcpc[K][rP][V][Vg]; // Hora de chegada no ponto de carga do atendimento do cliente c pelo veiculo k para a viagem v
// ----------------------------------------------------------------------------------------------------------------------
// Modelo 

minimize sum(i in V, j in V, k in K, p in rP)(x[i][j][k][p] * cr[i][j]) + 
	sum(i in V, j in V, k in K, p in rP: j > qP)( x[i][j][k][p] * cac[j][p]);

subject to {
	forall(j in V : j > qP){
		sum(i in V, k in K, p in rP)(x[i][j][k][p]) - sum(i in V, k in K, p in rP)(x[j][i][k][p]) == 0;	
	}
	
	forall(j in V : j > qP){
		sum(i in V, k in K, p in rP)(x[i][j][k][p]) == qv[j];
	}
	
	forall(k in K, p in rP, i in V, j in V, v in Vg : j > qP) {
		x[i][j][k][p] * (hiac[k][p][j][v] - hc[j][v]) == 0;
		x[i][j][k][p] * (hp[k][j][v] + tp[p] + ti[i][j] - hiac[k][p][j][v]) == 0;
		x[j][i][k][p] * (hiac[k][p][j][v] + td[j] - hfac[k][p][j][v]) == 0;
		x[j][i][k][p] * (hfac[k][p][j][v] + tv[j][i] - hcpc[k][p][j][v]) == 0;
	}
}
