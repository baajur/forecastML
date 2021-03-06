% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calculate_intervals.R
\name{calculate_intervals}
\alias{calculate_intervals}
\title{Calculate bootstrap prediction intervals for forecasts}
\usage{
calculate_intervals(
  forecasts,
  residuals,
  index = NULL,
  outcome = NULL,
  keys = NULL,
  levels = c(0.95),
  times = 100L,
  weights = NULL,
  keep_samples = FALSE
)
}
\arguments{
\item{forecasts}{A data.frame of forecasts.}

\item{residuals}{A data.frame of residuals (e.g., \code{residuals(data_fit)})}

\item{index}{Optional for forecasts from \code{combine_forecasts()}. A string giving the name of the
date column in \code{forecasts}.}

\item{outcome}{Optional for forecasts from \code{combine_forecasts()}. A string giving the name of the
forecast column in \code{forecasts}.}

\item{keys}{Optional. For grouped time series, a character vector giving the column name(s) of the
group columns. The key identifies unique time series of residuals for bootstrap sampling. For direct forecasting,
a single time series will have one group per direct forecast horizon.}

\item{levels}{A numeric vector with 1 or more forecast prediction intervals. A level of .95, for example, will
return the 0.25 and .975 quantiles of the bootstrapped forecast distribution at each forecast horizon.}

\item{times}{Integer. The number of bootstrap samples.}

\item{weights}{Not implemented.}

\item{keep_samples}{Boolean. If \code{TRUE}, a data.frame of \code{times} bootstrapped forecasts is returned
in addition to the calculated forecast prediction intervals. The samples are in the list slot named 'samples'.}
}
\value{
If \code{forecasts} is an object of class 'forecast_results', a \code{forecast_results} object
with a new column for each lower- and upper-bound forecast in \code{levels}. If \code{forecasts} is a
data.frame, the function return will be the same but without \code{forecastML} attributes. If,
\code{keep_samples} is \code{TRUE}, a named list of length 2 is returned with 'forecasts' and 'samples'.
}
\description{
The residuals from model training/fit are sampled i.i.d. for (a) each direct forecast
horizon for a single time series and (b) each combination of direct forecast horizon and
group for multiple time series.
}
\examples{
\dontrun{
  data("data_seatbelts", package = "forecastML")

  data_train <- create_lagged_df(data_seatbelts, type = "train", method = "direct",
                                 outcome_col = 1, lookback = 1:15,
                                 horizons = c(1, 6, 12))

  windows <- create_windows(data_train, window_length = 0)

  model_fn <- function(data) {
    model <- lm(DriversKilled ~ ., data)
  }

  model_results <- train_model(data_train, windows, model_name = "OLS",
                               model_function = model_fn)

  predict_fn <- function(model, data) {
    data_pred <- as.data.frame(predict(model, data))
  }

  data_fit <- predict(model_results, prediction_function = list(predict_fn), data = data_train)

  residuals <- residuals(data_fit)

  data_forecast <- create_lagged_df(data_seatbelts, type = "forecast",
                                    method = "direct", outcome_col = 1,
                                    lookback = 1:15, horizons = c(1, 6, 12))

  data_forecasts <- predict(model_results, prediction_function = list(predict_fn),
                            data = data_forecast)

  data_forecasts <- combine_forecasts(data_forecasts)

  data_forecasts <- calculate_intervals(data_forecasts, residuals, times = 30)

  plot(data_forecasts)
}
}
