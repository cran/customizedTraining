\name{cv.customizedGlmnet}
\alias{cv.customizedGlmnet}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
cross validation for customizedGlmnet
}
\description{
Does k-fold cross-validation for customizedGlmnet and returns a values for
\code{G} and \code{lambda}
}
\usage{
cv.customizedGlmnet(xTrain, yTrain, xTest = NULL, groupid = NULL, Gs = NULL,
    dendrogram = NULL, dendrogramCV = NULL, lambda = NULL,
    nfolds = 10, foldid = NULL, keep = FALSE,
    family = c("gaussian", "binomial", "multinomial"), verbose = FALSE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{xTrain}{
an n-by-p matrix of training covariates
}
  \item{yTrain}{
a length-n vector of training responses. Numeric for family = \code{"gaussian"}.
Factor or character for \code{family = "binomial"} or
\code{family = "multinomial"}
}
  \item{xTest}{
an m-by-p matrix of test covariates. May be left NULL, in which case cross
validation predictions are made internally on the training set and no test
predictions are returned.
}
  \item{groupid}{
an optional length-m vector of group memberships for the test set. If
specified, customized training subsets are identified using the union of
nearest neighbor sets for each test group, in which case cross-validation is
used only to select the regularization parameter \code{lambda}, not the number
of clusters \code{G}. Either \code{groupid} or \code{Gs} must be specified
}
  \item{Gs}{
a vector of positive integers indicating the numbers of clusters over which to
perform cross-validation to determine the best number. Ignored if \code{groupid}
is specified. Either \code{groupid} or \code{Gs} must be specified
}
  \item{dendrogram}{
optional output from \code{hclust} on the joint covariate data. Useful if method
is being used several times to avoid redundancy in calculations
}
  \item{dendrogramCV}{
optional output from \code{hclust} on the training covariate data. Used as joint
clustering result for cross-validation. Useful to specify in advance if method
is being used several times to avoid redundancy in calculations
}
  \item{lambda}{
sequence of values to use for the regularization parameter lambda. Recomended
to leave as NULL and allow \code{glmnet} to choose automatically.
}
  \item{nfolds}{
number of folds -- default is 10. Ignored if foldid is specified
}
  \item{foldid}{
an optional length-n vector of fold memberships used for cross-validation
}
  \item{keep}{
Should fitted values on the training set from cross validation be included in
output? Default is FALSE.
}
  \item{family}{
response type
}
  \item{verbose}{
Should progress be printed to console as folds are evaluated during
cross-validation? Default is FALSE.
}
}
%\details{
%%  ~~ If necessary, more details than the description above ~~
%}
\value{
an object of class \code{cv.customizedGlmnet}
  \item{call}{
the call that produced this object
}
  \item{G.min}{
unless groupid is specified, the number of clusters minimizing CV error
}
  \item{lambda}{
the sequence of values of the regularization parameter \code{lambda} considered
}
  \item{lambda.min}{
the value of the regularization parameter \code{lambda} minimizing CV error
}
  \item{error}{
a matrix containing the CV error for each \code{G} and \code{lambda}
}
  \item{fit}{
a \code{customizedGlmnet} object fit using \code{G.min} and \code{lambda.min}.
Only returned if \code{xTest} is not NULL.
}
  \item{prediction}{
a length-m vector of predictions for the test set, using the tuning parameters
which minimize cross-validation error. Only returned if \code{xTest} is not
NULL.
}
  \item{selected}{
a list of nonzero variables for each customized training set, using
\code{G.min} and \code{lambda.min}. Only returned if \code{xTest} is not NULL.
}
  \item{cv.fit}{
a array containing fitted values on the training set from cross validation.
Only returned if \code{keep} is TRUE.
}
}
\references{
Scott Powers, Trevor Hastie and Robert Tibshirani (2015) "Customized training
with an application to mass specrometric imaging of gastric cancer data."
Annals of Applied Statistics 9, 4:1709-1725.
}
\author{
Scott Powers, Trevor Hastie, Robert Tibshirani
}
%\note{
%%  ~~further notes~~
%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
\code{\link{customizedGlmnet}}, \code{\link{plot.cv.customizedGlmnet}},
\code{\link{predict.cv.customizedGlmnet}}
}
\examples{
require(glmnet)

# Simulate synthetic data

n = m = 150
p = 50
q = 5
K = 3
sigmaC = 10
sigmaX = sigmaY = 1
set.seed(5914)

beta = matrix(0, nrow = p, ncol = K)
for (k in 1:K) beta[sample(1:p, q), k] = 1
c = matrix(rnorm(K*p, 0, sigmaC), K, p)
eta = rnorm(K)
pi = (exp(eta)+1)/sum(exp(eta)+1)
z = t(rmultinom(m + n, 1, pi))
x = crossprod(t(z), c) + matrix(rnorm((m + n)*p, 0, sigmaX), m + n, p)
y = rowSums(z*(crossprod(t(x), beta))) + rnorm(m + n, 0, sigmaY)

x.train = x[1:n, ]
y.train = y[1:n]
x.test = x[n + 1:m, ]
y.test = y[n + 1:m]
foldid = sample(rep(1:10, length = nrow(x.train)))


# Example 1: Use clustering to fit the customized training model to training
# and test data with no predefined test-set blocks

fit1 = cv.customizedGlmnet(x.train, y.train, x.test, Gs = c(1, 2, 3, 5),
    family = "gaussian", foldid = foldid)

# Print the optimal number of groups and value of lambda:
fit1$G.min
fit1$lambda.min

# Print the customized training model fit:
fit1

# Compute test error using the predict function:
mean((y[n + 1:m] - predict(fit1))^2)

# Plot nonzero coefficients by group:
plot(fit1)


# Example 2: If the test set has predefined blocks, use these blocks to define
# the customized training sets, instead of using clustering.
foldid = apply(z == 1, 1, which)[1:n]
group.id = apply(z == 1, 1, which)[n + 1:m]

fit2 = cv.customizedGlmnet(x.train, y.train, x.test, group.id, foldid = foldid)

# Print the optimal value of lambda:
fit2$lambda.min

# Print the customized training model fit:
fit2

# Compute test error using the predict function:
mean((y[n + 1:m] - predict(fit2))^2)

# Plot nonzero coefficients by group:
plot(fit2)


# Example 3: If there is no test set, but the training set is organized into
# blocks, you can do cross validation with these blocks as the basis for the
# customized training sets.

fit3 = cv.customizedGlmnet(x.train, y.train, foldid = foldid)

# Print the optimal value of lambda:
fit3$lambda.min

# Print the customized training model fit:
fit3

# Compute test error using the predict function:
mean((y[n + 1:m] - predict(fit3))^2)

# Plot nonzero coefficients by group:
plot(fit3)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
