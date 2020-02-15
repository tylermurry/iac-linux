const ssh = new (require('node-ssh'))();

describe('IAC Linux Tests', () => {
  const {
    IAC_LINUX_IP_ADDRESS,
    IAC_LINUX_USERNAME,
    IAC_LINUX_PASSWORD
  } = process.env;

  beforeAll(async () => ssh.connect({ host: IAC_LINUX_IP_ADDRESS, username: IAC_LINUX_USERNAME, password: IAC_LINUX_PASSWORD }));
  afterAll(async () => ssh.dispose());

  it('should ssh into the linux vm and verify the os details are correct', async () => {
    expect(await ssh.exec('cat /etc/*-release')).toMatchSnapshot();
  });
});
