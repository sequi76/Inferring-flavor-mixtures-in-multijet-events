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
    int slice_length = end-start+1;

    for (k in 1:slice_length)
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
  array[N,4] int<lower=1, upper=m> score;  // b-tagging score for jet#1
  real<lower=0> permutation_factor;

}


parameters {
  vector<lower=0>[m-2] a_j;	
  simplex[m-1] w_j_mode;
  vector<lower=0>[m-2] a_b;	
  simplex[m-1] w_b_mode;
  simplex[3] theta; // mixture coefficient for the 3 classes
}



transformed parameters{
  ordered[2] y5;   // this parameter will reinforce correct labelling, avoiding label switch. Because the 5th bin class0 i s greater than class1 always
  ordered[2] y20;

  vector[m-1] p_j;  
  p_j=rep_vector(0.0, m-1);  					// creates null vector of size K
  for(k in 1:m-1){
    vector[m-1] logp_j;
    vector[m-2] sign_j;
    sign_j = rep_vector(-1.0,m-2);				// creates vector smaller in one element, with all components equal to -1
    if (k>=2)
      sign_j[1:(k-1)] = rep_vector(1.0,k-1);			// put +1 up to k-1, and leave others in -1
    logp_j = append_row(0.0,   cumulative_sum (sign_j .* a_j));	// each component is the sum of all the previous one in cumulative_sum 
								// (kind of an integral).  x .*= y means x = x * y element-wise.
    p_j =  p_j + softmax(logp_j)  *  w_j_mode[k];                 // Here there is some magic. You are doing a w_mode-weighted-average of 

   }


  vector[m-1] p_b;  
  p_b=rep_vector(0.0, m-1);  					
  for(k in 1:m-1){
    vector[m-1] logp_b;
    vector[m-2] sign_b;
    sign_b = rep_vector(-1.0,m-2);				
    if (k>=2)
      sign_b[1:(k-1)] = rep_vector(1.0,k-1);			
    logp_b = append_row(0.0,   cumulative_sum (sign_b .* a_b));	
								
    p_b =  p_b + softmax(logp_b)  *  w_b_mode[k];                 
   }								
  y5[1] = p_b[8];			// let's try this to avoid label switch,  I 've changed to bin 8, because it was failing with bin 5... too close to the start...
  y5[2] = p_j[8];
		
  y20[1] = p_j[20];
  y20[2] = p_b[20];		
}

model {
  int grainsize = 1;
  theta ~ dirichlet([1,1,1]);
  a_j ~ normal(0,0.5);
  a_b ~ normal(0,0.5);
  w_b_mode ~ dirichlet( rep_vector(1.0/(m-1), m-1) );  
  w_j_mode ~ dirichlet( rep_vector(1.0/(m-1), m-1) );  

  target += reduce_sum(partial_sum, score, grainsize, p_j, p_b, theta);


}
