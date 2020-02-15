const ssh = new (require('node-ssh'))();

describe('IAC Linux Tests', () => {
  beforeAll(async () => ssh.connect({
    host: process.env.IAC_LINUX_IP_ADDRESS,
    username: process.env.IAC_LINUX_USERNAME,
    password: process.env.IAC_LINUX_PASSWORD
  }));

  afterAll(async () => ssh.dispose());

  it('should ssh into the linux vm and verify the os details are correct', async () => {
    expect(await ssh.exec('cat /etc/*-release')).toMatchSnapshot();
  });
});
