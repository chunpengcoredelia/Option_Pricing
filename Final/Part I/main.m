% Initialising the values 
set_parameters;

% Finding J such that the error is < 0.05
J = minimizeAbsError(K1,K2,T,r,sigma,Smin,Smax,N);

% Calculate the option prices numerically and with Black-Scholes
[V_PDE, S] = PDE_bullspread(K1, K2, T, r, sigma, Smin, Smax, N, J);
V_BS = BS_bullspread(S); 

% Plotting the result
 plotComparison(S, V_PDE, V_BS)

% Monte-Carlo 
[times, prices, variances, errors, sample_sizes] = MonteCarloBullspread(Smin, Smax, K1, K2, r, sigma, T, N, payoff, BS_bullspread);

% Plotting the different methods
plotMonteCarlo(Smin, Smax, prices)

% Printing the results
printResults(times, prices, variances, errors, sample_sizes);
% TODO: DELTA STUFF

% compare_monte_carlo(price_BS, mean(price), mean(variance), mean(time), mean(errors), sample_size_mc)
% 
% 
% % DELTA FOR MONTE CARLO
