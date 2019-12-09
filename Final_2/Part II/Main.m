%% PRICING A PUT OPTION
SetParameters;

%% Plotting the local volatility model
PlotVolatility(Smin, Smax, T, volatility);

%% Local volatility and time-dependent interest rates
% To get the sample sizes
fprintf("Pricing a put option with local volatility and time-dependent interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(K, Smin, Smax, rate, volatility, dt, T, M, put_payoff, 0);
PlotMonteCarlo(Smin, Smax, prices, 0);
PrintResults(times, variances, sample_sizes)
PlotSampleSizes(Smin, Smax, sample_sizes, 0);

%% Local volatility and time-dependent interest rates
% With the corresponding sample sizes
fprintf("Pricing a put option with local volatility and time-dependent interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(K, Smin, Smax, rate, volatility, dt, T, max(ceil(sample_sizes')), put_payoff, 0);
PlotMonteCarlo(Smin, Smax, prices, 0);
PrintResults(times, variances, sample_sizes)
PlotSampleSizes(Smin, Smax, sample_sizes, 0);

%% Constant volatility and interest rates
fprintf("\nPricing a put option with constant volatility and interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(K, Smin, Smax, r(1), sigma(1), dt, T, max(ceil(sample_sizes')), put_payoff, 0);
PlotMonteCarlo(Smin, Smax, prices, 0);
PrintResults(times, variances, sample_sizes)
PlotSampleSizes(Smin, Smax, sample_sizes, 0);

%% Comparing the distribution of our geometric Brownian model and the assumption made in control variates
DistributionComparison;

%% PRICING A DOWN AND OUT BARRIER PUT OPTION
%% Local volatility and stoch. interest rates
fprintf("\nPricing a down and out barrier put option with local volatility and time-dependent interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(K, Smin, Smax, rate, volatility, dt, T, M, barrier_payoff, barrier);
PlotMonteCarlo(Smin, Smax, prices, barrier);
PrintResults(times, variances, sample_sizes)
PlotSampleSizes(Smin, Smax, sample_sizes, barrier);

%% Local volatility and stochastic interest rates - different barriers, Sb, ranging from 0-50 (5:8:45)
M_Sb = round(max(sample_sizes(1,:)));
BarrierComparison(K, Smin, Smax, rate, volatility, dt, T, 1000, barrier_payoff);
BarrierDeltaComparison(Smin, Smax, rate, volatility, dt, T, 1000, barrier_payoff);

%% Constant volatility and interest rates - different barriers, Sb, ranging from 0-50 (5:8:45)
BarrierComparison(K, Smin, Smax, r(1), sigma(1), dt, T, M, barrier_payoff, barrier);

%% Constant volatility and interest rates
fprintf("\nPricing a down and out barrier put option with constant volatility and interest rates\n")
[times, prices, variances, sample_sizes] = MonteCarlo(K, Smin, Smax, rate(0), sigma(1), dt, T, M, barrier_payoff, barrier);
PlotMonteCarlo(Smin, Smax, prices, barrier);
PrintResults(times, variances, sample_sizes)
PlotSampleSizes(Smin, Smax, sample_sizes, barrier);

%% DELTA
delta = AntitheticDelta(M, rate, volatility, dt, T, Smin, Smax, barrier_payoff, barrier);
PlotDelta(Smin,Smax,delta);

%% BARRIER VS PUT COMPARISON - LOCAL VOLATILITY 
% Discuss difference to BSM model - const vol and rates
[times_put, prices_put, variances_put, sample_sizes_put] = MonteCarlo(K, Smin, Smax, rate, volatility, dt, T, M, put_payoff, 0);
[times_barrier, prices_barrier, variances_barrier, sample_sizes_barrier] = MonteCarlo(K, Smin, Smax, rate, volatility, dt, T, M, barrier_payoff, 0);
%%
plot(Smin:Smax, prices_put(1,:),'LineWidth',1)
hold on
plot(Smin:Smax, prices_barrier(1,:),'LineWidth',1)
hold on
plot(Smin:Smax, option_price, 'k--','Linewidth', 1)
grid on
xlabel('Stock price (�)', 'FontSize',14)
ylabel('Option price (�)', 'FontSize',14)
legend('Vanilla put','Down-and-out put','Black Scholes solution','FontSize',14)

%%
% Discuss difference to BSM model - const vol and rates
[times_put, prices_put, variances_put, sample_sizes_put] = MonteCarlo(K, Smin, Smax, r(1), sigma(1), dt, T, M, put_payoff, 0);
[times_barrier, prices_barrier, variances_barrier, sample_sizes_barrier] = MonteCarlo(K, Smin, Smax, r(1), sigma(1), dt, T, M, barrier_payoff, 0);

plot(Smin:Smax, prices_put(1,:),'LineWidth',1)
hold on
plot(Smin:Smax, prices_barrier(1,:),'LineWidth',1)
hold on
plot(Smin:Smax, option_price, 'k--','Linewidth', 1)
grid on
xlabel('Stock price (�)', 'FontSize',14)
ylabel('Option price (�)', 'FontSize',14)
legend('Vanilla put','Down-and-out put','Black Scholes solution','FontSize',14)

