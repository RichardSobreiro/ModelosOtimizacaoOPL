int qViagens = ...; // Quantidade de viagens
int qPontosCarga = ...; // Quantidade de pontos de carga que podem produzir concreto para atendimento das viagens
int M = ...;
// Conjuntos

range I = 1..qViagens;
range K = 1..qPontosCarga;

// Parâmetros

float dp[I][K] = ...; // Tempo gasto para pesagem da viagem v no ponto de carga p
float hs[I] = ...; // Horario solicitado pelo cliente para chegada da viagem v

// Variáveis 

dvar float tfp[I]; // Instante final da pesagem da viagem v
dvar boolean x[I][I][K]; // Se a viagem v precede imediatamente a viagem v no ponto de carga p
dvar float atr[I]; // Atraso da viagem v
dvar float avn[I]; // Avanço da viagem v

// Modelo

minimize sum(v in I)(atr[v] + avn[v]);

subject to {
	forall(v in I : v > 1){
		sum(p in K, i in I)(x[i][v][p]) >= 1;
		sum(p in K, i in I)(x[i][v][p]) <= 1;
	}
	
	forall(p in K){
		sum(v in I : v > 1)(x[1][v][p]) <= 1;	
	}
	
	forall(h in I, p in K : h > 1){
		sum(i in I : i != h)(x[i][h][p]) - sum(j in I : j != h)(x[h][j][p])	>= 0;
		sum(i in I : i != h)(x[i][h][p]) - sum(j in I : j != h)(x[h][j][p])	<= 0;
	}
	
	forall(i in I, j in I : j > 1){
		tfp[j] >= tfp[i] + sum(p in K)(x[i][j][p] * (dp[i][p])) + M * (sum(p in K)(x[i][j][p]) - 1);
	}
	AtrasoAvancoDasVaigens:
	forall(i in I){
		atr[i] >= tfp[i] - hs[i];
		avn[i] >= hs[i] - tfp[i];
	}
	NaoNegatividadeDasVariaveisReais:
	forall(i in I){
		atr[i] >= 0;
		avn[i] >= 0;	
	}
}

execute {
	for(var i in I){
		for(var j in I){
			for(var k in K){
				if(x[i][j][k] == 1){
					writeln("-------------------------------------------------------------------");
					writeln("Ponto de carga ", k, " atende a viagem ", j, " após a viagem ", i, " !");
					writeln("Horário solicitado: ", hs[j], " X Horário encontrado: ", tfp[j]);
					writeln("Atraso: ", atr[j], " X Avanço: ", avn[j]);
					writeln("-------------------------------------------------------------------");
				}			
			}	
		}	
	}
}



