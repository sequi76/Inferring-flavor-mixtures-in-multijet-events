functions {
  real partial_sum(array[,] int score_slice,
                   int start, int end,
                   vector yj,
                   vector yb,
                   vector theta)
{ 
    real permutation_factor = 1.0/6;
    real partial_target = 0;
    vector[3] lp;
    vector[6] lp2;
  
    for (k in 1:(end-start+1))
         {
         lp2[1] = log(permutation_factor) + log(yj)[score_slice[k,1]] + log(yj)[score_slice[k,2]] + log(yb)[score_slice[k,3]] + log(yb)[score_slice[k,4]];
         lp2[2] = log(permutation_factor) + log(yj)[score_slice[k,1]] + log(yb)[score_slice[k,2]] + log(yj)[score_slice[k,3]] + log(yb)[score_slice[k,4]];
         lp2[3] = log(permutation_factor) + log(yj)[score_slice[k,1]] + log(yb)[score_slice[k,2]] + log(yb)[score_slice[k,3]] + log(yj)[score_slice[k,4]];
         lp2[4] = log(permutation_factor) + log(yb)[score_slice[k,1]] + log(yj)[score_slice[k,2]] + log(yj)[score_slice[k,3]] + log(yb)[score_slice[k,4]];
         lp2[5] = log(permutation_factor) + log(yb)[score_slice[k,1]] + log(yj)[score_slice[k,2]] + log(yb)[score_slice[k,3]] + log(yj)[score_slice[k,4]];
         lp2[6] = log(permutation_factor) + log(yb)[score_slice[k,1]] + log(yb)[score_slice[k,2]] + log(yj)[score_slice[k,3]] + log(yj)[score_slice[k,4]];

         lp[1] = log(yj)[score_slice[k,1]] + log(yj)[score_slice[k,2]] + log(yj)[score_slice[k,3]] + log(yj)[score_slice[k,4]];
         lp[2] = log_sum_exp(lp2);  
         lp[3] = log(yb)[score_slice[k,1]] + log(yb)[score_slice[k,2]] + log(yb)[score_slice[k,3]] + log(yb)[score_slice[k,4]];

         partial_target += log_mix(theta, lp);
         }

    return partial_target;
  }
 } 



    data {
      int<lower=1> m;  // steps in the discretization
      int<lower=1> N;  // data points
      array[N,4] int<lower=1, upper=m> score;  // b-tagging score for jets
      real<lower=1> sigma0;              // Normalization factor
      real<lower=1> sigma1;              // Normalization factor
      vector<lower=0>[m-1] muj;                  // central value of prior b-tagging distribution for j-jets
      vector<lower=0>[m-1] mub;                  // central value of prior b-tagging distribution for b-jets
    }
    transformed data {
      // We define the covariance matrix starting from the hyperparameters: m, sigma & correlation
      vector<lower=0>[m-1] etaj;
      vector<lower=0>[m-1] etab;
      for (i in 1:m-1)
      {
        etaj[i] = sigma0 * muj[i];
        etab[i] = sigma1 * mub[i];
        }
    }
    parameters {
      simplex[m-1] yj;   // posterior samples of b-tagging distribution for j-jets
      simplex[m-1] yb;   // posterior samples of b-tagging distribution for b-jets
      simplex[3] theta; // misture coefficient for the 3 classes: bbbb, bbjj (in any order) & jjjj          

    }
    model {
      int grainsize = 1;
      theta ~ dirichlet([1.0,1.0,1.0]);
      yj ~ dirichlet(etaj);  
      yb ~ dirichlet(etab); 
      vector[3] lp;
      vector[6] lp2;

      target += reduce_sum(partial_sum, score, grainsize, yj, yb, theta);
    }

