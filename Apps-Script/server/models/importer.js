class Importer {
  constructor(args) {
    Logger.log(`Pinging ABify: ${ABify.wakeUp()}`);

    this.id = args.id || this.generateImportID(args);
    this.subdomain = args.subdomain;
    this.siteName = args.siteName;
    this.template = args.template;
    this.spreadsheet = new Spreadsheet;
    this.sheet = new Sheet;
    this.credentials = Credentials.getCredentialsForSite(this.siteName, this.spreadsheet.id);
    this.ABify = new ABify({ creds: this.credentials });
  }

  start() {
    const startResp = this.ABify.start(this.sheet.data, this.template);
    this.id = startResp.import_id;
    Logger.log(JSON.stringify(startResp));
  }

  generateImportID(args) {
    const timestamp = new Date().toISOString().replace(/[-:T.]/g, '').slice(0, 14);
    return `${timestamp}${args.subdomain ? "-" + args.subdomain : ""}-${StringUtils.generateString(8)}`;
  }

  monitor() {
    Logger.log('Monitoring import');
    while (1) {
      const status = Redis.get(this.id);
      const completedRows = ResultsHandler.getLastCompletedRowIdx(status.data);
      Logger.log(`Status: ${status.status}, run time: ${status.run_time}, progress: ${completedRows}/${status.data.length}`);
      if (status.status === 'complete') {
        return status;
      }
      Utilities.sleep(1000);
    }
  }
}