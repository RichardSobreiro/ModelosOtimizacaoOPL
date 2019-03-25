int qNos = ...;
int qClusters = ...;
int qPontosCarga = ...;
int qBetoneiras = ...;

float Mc = ...;
float Mt = ...;
float M = ...;

// Conjuntos

range I = 1..qNos;
//range K = 1..qClusters;
range P = 1..qPontosCarga;
range V = 1..qBetoneiras;

// Par�metros

//float Delta = ...; // Tempo m�ximo de espera da betoneira entre dois clusters
float rhoi[I] = ...; // Custo de viola��o da janela de tempo para o n� i
float rhov[V] = ...; // Custo de viola��o do tempo m�ximo de trabalho para a betoneira v
float a[I] = ...; // Ini�cio da janela de atendimento do no i
//float aCk[K] = ...; // In�cio da janela de atendimento do cluster Ck
float b[I] = ...; // Final da janela de tempo de atendimento do no i
//float bCk[K] = ...; // Final da janela de tempo de atendimento do no i
float c[V][I][I] = ...; // Custo do percurso entre o no i e j para a betoneira v
float cf[V] = ...; // Custo fixo de uso da betoneira v
float dMax = ...; // Dist�ncia m�xima para nos dentro de um cluster
float q[V] = ...; // Capacidade da betoneira b
float st[I][V] = ...; // Hor�rio de chegada da betoneira v no n� i
//float stC[K][V] = ...; // Hor�rio de chegada efetivo da betoneira v para o cluster k
float t[V][I][I] = ...; // Tempo m�dio de viagem entre no i e o n� j para o ve�culo v
float tvMax[V] = ...; // Tempo m�ximo de trabalho para o ve�culo v
float w[I] = ...; // Demanda no n� i
//	float wC[K] = ...; // Demanda do cluster k
float ctr = ...; // Custo de trabalho por minuto

// Vari�veis

dvar boolean S[I][I]; // N� i � visitado antes/depois do n� j
dvar boolean X[P][V]; // Ve�culo v � atribu�do ao ponto de carga p
dvar boolean Y[I][V]; // Ve�culo v � atribu�do ao n� v
dvar float DeltaA[I]; // Janela de tempo que denota quanto tempo o ve�culo chegou mais cedo no n� i
dvar float DeltaB[I]; // Janela de tempo que denota quanto tempo o ve�culo chegou mais tarde no n� i
dvar float DeltaT[V]; // Quanto tempo o ve�culo v trabalho mais que o m�ximo permitido para o mesmo
dvar float C[I]; // Custo acumulado devido a dist�ncia at� o n� i
dvar float CV[V]; // Custo total devido a dist�ncia percorrida pelo ve�culo v
dvar float T[I]; // Hor�rio de chegada do ve�culo no n� i
dvar float TV[V]; // Tempo total do percurso realizado pelo ve�culo v

// Modelo

minimize sum(v in V)((cf[v] * sum(p in P)(X[p][v])) + (ctr * TV[v]) + CV[v] + (rhov[v] * DeltaT[v])) + 
	sum(i in I)(rhoi[i] * (DeltaA[i] + DeltaB[i]));
	
subject to {
	AtribuicaoDeNosAosVeiculos:
	forall(i in I){
		sum(v in V)(Y[i][v]) <= 1;
		sum(v in V)(Y[i][v]) >= 1;	
	}
	AtribuicaoDeVeiculosAosDepositos:
	forall(v in V){
		sum(p in P)(X[p][v]) <= 1;	
	}
	CustoMinimoDeViagemDoVeiculoParaChegarAoNo:
	forall(i in I, p in P, v in V){
		C[i] >= c[v][p][i] * (X[p][v] + Y[i][v] - 1);	
	}
	RelacaoEntreOCustosDeViagemAteOsNosSeOsMesmosEstaoNoMesmoTour:
	forall(i in I, j in I, v in V : i < j){
		C[j] >= C[i] + c[v][i][j] - Mc * (1 - S[i][j]) - Mc * (2 - Y[i][v] - Y[j][v]);
		C[i] >= C[j] + c[v][j][i] - Mc * S[i][j] - Mc * (2 - Y[i][v] - Y[j][v]);
	}
	CustoTotalDoTourDoVeiculo:
	forall(i in I, p in P, v in V){
		CV[v] >= C[i] + c[v][i][p] - Mc * (2 - X[p][i] - Y[i][v]);	
	}
	TempoDeChegadaDoNo:
	forall(i in I, p in P, v in V){
		T[i] >= t[v][p][i] * (X[p][v] + Y[i][v] - 1);	
	}
	RelacaoEntreOTempoDeChegadaDaViagemNosNohsSeOsMesmosEstaoNoMesmoTour:
	forall(i in I, j in I, v in V : i < j){
		T[j] >= T[i] + st[i][v] + t[v][i][j] - Mt * (1 - S[i][j]) - M * (2 - Y[i][v] - Y[j][v]);
		T[i] >= T[j] + st[j][v] + t[v][j][i] - Mt * (S[i][j]) - M * (2 - Y[i][v] - Y[j][v]);	
	}
	TempoTotalDeViagemParaVeiculo:
	forall(i in I, p in P, v in V){
		TV[v] >= T[i] + st[i][v] + t[v][i][p] - Mt * (2 - X[p][v] - Y[i][v]);	
	}
	JanelaDeTempoDevidoAChegadaAdiantada:
	forall(i in I){
		DeltaA[i] >= a[i] - T[i];	
	}
	JanelaDeTempoDevidoAChegadaAtrasada:
	forall(i in I){
	 	DeltaB[i] >= T[i] - b[i];	
	}
	JanelaDeTempoDevidoAoTempoMaximoDeTrabalhoParaCadaVeiculo:
	forall(v in V){
		DeltaT[v] >= TV[v] - tvMax[v];	
	}
	RestricoesDeCapacidade:
	forall(v in V){
		sum(i in I)(w[i] * Y[i][v]) <= q[v] * (sum(p in P)(X[p][v]));
	}
	
	forall(i in I){
		T[i] >= 0;
		C[i] >= 0;
		DeltaA[i] >= 0;
		DeltaB[i] >= 0;
	}
	
	forall(v in V){
		TV[v] >= 0;
		CV[v] >= 0;
		DeltaT[v] >= 0;	
	}
}

execute{
	for(var p in P){
		for(var v in V){
			for(var i in V){
				if((X[p][v] == 1) && (Y[i][v] == 1)){
					writeln("-------------------------------------------------------------------------------------------");
					writeln("N� ",i," � atendido pelo ve�culo ",v," do ponto de carga ",p," �s ", T[i]);
					writeln("-------------------------------------------------------------------------------------------");
				}			
			}		
		}	
	}
}






