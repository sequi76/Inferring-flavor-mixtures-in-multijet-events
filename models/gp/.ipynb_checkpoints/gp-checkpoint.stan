data {
  int<lower=1> m;  // steps in the discretization
  int<lower=1> N;  // data points
  array[N] int<lower=1, upper=m> score1;  // b-tagging score for jet#1 
  array[N] int<lower=1, upper=m> score2;  // b-tagging score for jet#2 
  array[N] int<lower=1, upper=m> score3;  // b-tagging score for jet#3 
  array[N] int<lower=1, upper=m> score4;  // b-tagging score for jet#4 
  vector[m-1] muj;                  // central value of prior b-tagging distribution for j-jets
  vector[m-1] mub;                  // central value of prior b-tagging distribution for b-jets
  real<lower=0> permutation_factor;
  real<lower=0> mu_sigma;
  real<lower=0> sigma_sigma;
  real<lower=0> mu_correlation;
  real<lower=0> sigma_correlation;      
}

parameters {
  ordered[2] y8;   // this parameter will reinforce correct labelling, avoiding label switch. Because the 5th bin class0 i s greater than class1 always
  ordered[2] y18;   // this parameter will reinforce correct labelling, avoiding label switch. Because the 5th bin class0 i s greater than class1 always
  vector[m-3] yj_remain;   // posterior samples of b-tagging distribution for j-jets
  vector[m-3] yb_remain;   // posterior samples of b-tagging distribution for b-jets
  simplex[3] theta; // misture coefficient for the 3 classes: bbbb, bbjj (in any order) & jjjj
  real<lower=0> sigma;              // Covariance matrix parameter
  real<lower=0> correlation;        // Covariance matrix parameter  
}

transformed parameters {    
  vector[m-1]  yj;
  vector[m-1]  yb;
  
  yb[1:7]= yb_remain[1:7];
  yb[8] = y8[1];
  yb[9:17] = yb_remain[8:16];
  yb[18] = y18[2];
  yb[19:m-1] =  yb_remain[17:(m-3)];

  yj[1:7]= yj_remain[1:7];
  yj[8] = y8[2];
  yj[9:17] = yj_remain[8:16];
  yj[18] = y18[1];
  yj[19:m-1] =  yj_remain[17:(m-3)];

}

model {
  sigma ~ normal(mu_sigma, sigma_sigma);
  correlation ~ normal(mu_correlation, sigma_correlation);
  theta ~ dirichlet([1,1,1]);
  vector[3] lp;
  vector[6] lp2;
  matrix[m-1, m-1] K;
  for (i in 1:m-1)
     for (j in 1:m-1)
       K[i, j] = sigma * exp( - pow((abs(i-j)/(correlation)),2));
  yj ~ multi_normal(muj, K);  
  yb ~ multi_normal(mub, K); 
  for (Ni in 1:N)     
     {
     lp2[1] = log(permutation_factor) + log_softmax(yj)[score1[Ni]] + log_softmax(yj)[score2[Ni]] + log_softmax(yb)[score3[Ni]] + log_softmax(yb)[score4[Ni]];
     lp2[2] = log(permutation_factor) + log_softmax(yj)[score1[Ni]] + log_softmax(yb)[score2[Ni]] + log_softmax(yj)[score3[Ni]] + log_softmax(yb)[score4[Ni]];
     lp2[3] = log(permutation_factor) + log_softmax(yj)[score1[Ni]] + log_softmax(yb)[score2[Ni]] + log_softmax(yb)[score3[Ni]] + log_softmax(yj)[score4[Ni]];
     lp2[4] = log(permutation_factor) + log_softmax(yb)[score1[Ni]] + log_softmax(yj)[score2[Ni]] + log_softmax(yj)[score3[Ni]] + log_softmax(yb)[score4[Ni]];
     lp2[5] = log(permutation_factor) + log_softmax(yb)[score1[Ni]] + log_softmax(yj)[score2[Ni]] + log_softmax(yb)[score3[Ni]] + log_softmax(yj)[score4[Ni]];
     lp2[6] = log(permutation_factor) + log_softmax(yb)[score1[Ni]] + log_softmax(yb)[score2[Ni]] + log_softmax(yj)[score3[Ni]] + log_softmax(yj)[score4[Ni]];

     lp[1] = log_softmax(yj)[score1[Ni]] + log_softmax(yj)[score2[Ni]] + log_softmax(yj)[score3[Ni]] + log_softmax(yj)[score4[Ni]];
     lp[2] = log_sum_exp(lp2);  
     lp[3] = log_softmax(yb)[score1[Ni]] + log_softmax(yb)[score2[Ni]] + log_softmax(yb)[score3[Ni]] + log_softmax(yb)[score4[Ni]];

     target += log_mix(theta, lp);
     }
}
