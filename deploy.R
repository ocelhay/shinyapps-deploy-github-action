.libPaths("/usr/local/lib/R/site-library")
cat("loading packages from:", paste("\n - ", .libPaths(), collapse = ""), "\n\n")

# use renv to detect and install required packages.
if (file.exists("renv.lock")) {
  renv::restore(prompt = FALSE)
} else {
  renv::hydrate()
}

# set up some helper functions for fetching environment variables
defined <- function(name) {
  !is.null(Sys.getenv(name)) && Sys.getenv(name) != ""
}
required <- function(name) {
  if (!defined(name)) {
    stop("!!! input or environment variable '", name, "' not set")
  }
  Sys.getenv(name)
}
optional <- function(name) {
  if (!defined(name)) {
    return(NULL)
  }
  Sys.getenv(name)
}

# resolve app dir
# Note that we are likely already executing from the app dir, as
# github sets the working directory to the workspace path on starting
# the docker image.
appDir <- ifelse(
  defined("INPUT_APPDIR"),
  required("INPUT_APPDIR"),
  required("GITHUB_WORKSPACE")
)

# required inputs
appName <- required("INPUT_APPNAME")
accountName <- required("INPUT_ACCOUNTNAME")
accountToken <- required("INPUT_ACCOUNTTOKEN")
accountSecret <- required("INPUT_ACCOUNTSECRET")

# optional inputs
appFiles <- optional("INPUT_APPFILES")
appFileManifest <- optional("INPUT_APPFILEMANIFEST")
appTitle <- optional("INPUT_APPTITLE")
logLevel <- optional("INPUT_LOGLEVEL")

# process appFiles
if (!is.null(appFiles)) {
  appFiles <- unlist(strsplit(appFiles, ",", TRUE))
}

# set up account
cat("checking account info...")
rsconnect::setAccountInfo(accountName, accountToken, accountSecret)
cat(" [OK]\n")


renviron_content <- paste0(
  "AIRTABLE_TOKEN=", required("INPUT_AIRTABLE_TOKEN"), "\n",
  "S3_BUCKET=", required("INPUT_S3_BUCKET")), "\n"
  "AWS_ACCESS_KEY_ID=", required("INPUT_AWS_ACCESS_KEY_ID")), "\n"
  "AWS_SECRET_ACCESS_KEY=", required("INPUT_AWS_SECRET_ACCESS_KEY")), "\n"
)

# Define the path for the .Renviron file
renviron_path <- file.path(appDir, ".Renviron")

# Write the content to the .Renviron file
writeLines(renviron_content, renviron_path)


# deploy application
rsconnect::deployApp(
  appDir = appDir,
  appFiles = appFiles,
  appFileManifest = appFileManifest,
  appName = appName,
  appTitle = appTitle,
  account = accountName,
  forceUpdate = TRUE
)
