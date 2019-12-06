%% PRICING A PUT OPTION
SetParameters;

%% Local volatility and stoch. interest rates
fprintf("Pricing a put option with local volatility and stochastic interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(K, Smin, Smax, rate, volatility, dt, T, M, put_payoff, 0);
PlotMonteCarlo(Smin, Smax, prices, option_price);
PrintResults(times, variances, sample_sizes)
PlotResults(sample_sizes);

%% Constant volatility and interest rates
fprintf("\nPricing a put option with constant volatility and interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(K, Smin, Smax, r(1), sigma(1), dt, T, M, put_payoff, 0);
PlotMonteCarlo(Smin, Smax, prices, option_price);
PrintResults(times, variances, sample_sizes)
PlotResults(sample_sizes);

%% PRICING A DOWN AND OUT BARRIER PUT OPTION
%% Local volatility and stoch. interest rates
fprintf("\nPricing a down and out barrier put option with local volatility and stochastic interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(K, Smin, Smax, rate, volatility, dt, T, M, barrier_payoff, 30);
PlotMonteCarlo(Smin, Smax, prices, option_price);
PrintResults(times, variances, sample_sizes)
PlotResults(sample_sizes);

%% Constant volatility and interest rates
fprintf("\nPricing a down and out barrier put option with constant volatility and interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(Smin, Smax, r(1), sigma(1), dt, T, M, barrier_payoff, 0);
PlotMonteCarlo(Smin, Smax, prices, option_price);
PrintResults(times, variances, sample_sizes)
PlotResults(sample_sizes);

%% Constant volatility and interest rates - different barriers, Sb, ranging from 0-50 (5:8:45)
BarrierComparison(Smin, Smax, rate, volatility, dt, T, M, barrier_payoff)