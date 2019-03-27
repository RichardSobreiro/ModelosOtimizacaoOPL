int qViagens = ...; // Quantidade de viagens
int qPontosCarga = ...; // Quantidade de pontos de carga que podem produzir concreto para atendimento das viagens
int qBetoneiras = ...; // Quantidade de betoneiras
int M = ...;
// Conjuntos

range I = 1..qViagens;
range K = 1..qPontosCarga;
range B = 1..qBetoneiras;

// Parâmetros

float dp[I][K] = ...; // Tempo gasto para pesagem da viagem v no ponto de carga p
float dv[I][K] = ...; // Tempo gasto no trajeto entre o ponto de carga p e o cliente da viagem i
float hs[I] = ...; // Horario solicitado pelo cliente para chegada da viagem v

// Variáveis 

dvar float tfp[I]; // Instante final da pesagem da viagem v
dvar float tfb[I]; // Instante final de antedimento da viagem v
dvar boolean x[I][I][K]; // Se a viagem v precede imediatamente a viagem v no ponto de carga p
dvar boolean y[I][I][B]; // Se a betoneira b atende a viagem j após a viagem i
dvar float atr[I]; // Atraso da viagem v
dvar float avn[I]; // Avanço da viagem v

// Modelo

minimize sum(v in I)(atr[v] + avn[v]);

subject to {
	forall(v in I : v > 1){
		sum(p in K, i in I)(x[i][v][p]) >= 1;
		sum(p in K, i in I)(x[i][v][p]) <= 1;
	}
	
	forall(v in I) {
		sum(b in B, i in I)(y[i][v][b]) >= 1;
		sum(b in B, i in I)(y[i][v][b]) <= 1;
	}
	
	forall(p in K){
		sum(v in I : v > 1)(x[1][v][p]) <= 1;	
	}
	
	forall(b in B){
		sum(v in I : v > 1)(y[1][v][b]) <= 1;	
	}
	
	forall(h in I, p in K : h > 1){
		sum(i in I : i != h)(x[i][h][p]) - sum(j in I : j != h)(x[h][j][p])	>= 0;
		sum(i in I : i != h)(x[i][h][p]) - sum(j in I : j != h)(x[h][j][p])	<= 0;
	}
	
	forall(h in I, b in B : h > 1){
		sum(i in I : i != h)(y[i][h][b]) - sum(j in I : j != h)(y[h][j][b])	>= 0;
		sum(i in I : i != h)(y[i][h][b]) - sum(j in I : j != h)(y[h][j][b])	<= 0;
	}
	
	forall(i in I, j in I : j > 1){
		tfp[j] >= tfp[i] + sum(p in K)(x[i][j][p] * (dp[i][p])) + M * (sum(p in K)(x[i][j][p]) - 1);
	}
	
	forall(i in I, j in I: j > 1){
		tfb[j] >= tfb[i] + tfp[j] + (2 * sum(b in B, p in K)(y[i][j][b] * dv[j][p])) +  M * (sum(b in B)(y[i][j][b]) - 1);	
	}
	
	AtrasoAvancoDasVaigens:
	forall(i in I){
		atr[i] >= tfb[i] - hs[i];
		avn[i] >= hs[i] - tfb[i];
	}
	NaoNegatividadeDasVariaveisReais:
	forall(i in I){
		atr[i] >= 0;
		avn[i] >= 0;
		tfp[i] >= 0;
		tfb[i] >= 0;	
	}
}

execute {
	for(var i in I){
		for(var j in I){
			for(var b in B){
				if(y[i][j][b] == 1){
					writeln("-------------------------------------------------------------------");
					writeln("Betoneira ", b, " atende a viagem ", j, " após a viagem ", i, " !");
					writeln("1 - Horário final da viagem ",i ,": ", tfb[i]);
					writeln("2 - Horário solicitado da viagem ",i ,": ", hs[i]);
					writeln("1 - Horário de pesagem da viagem ",i , ": ", tfp[i]);
					writeln("2 - Horário final da viagem ",j ,": ", tfb[j]);
					writeln("2 - Horário solicitado da viagem ",j ,": ", hs[j]);
					writeln("2 - Horário de pesagem da viagem ",j , ": ", tfp[j]);
					/*writeln("x[",i,"][",j,"][", 1,"] = ", x[i][j][1]);
					//writeln("Tempo entre ponto carga e ",j ,": ",((2 * dv[j][b])));
					writeln("tfb[i](", i,") + tfp[j](", j, ") + Janela de j (",j , ") : ", tfb[i] + tfp[j] + (2 * dv[j][1]));
					writeln("Horário solicitado: ", hs[j], " X Horário encontrado: ", tfb[j]);
					writeln("Atraso: ", atr[j], " X Avanço: ", avn[j]);*/
					writeln("-------------------------------------------------------------------");
				}			
			}	
		}	
	}
}



