#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>
#include <math.h>
#include <time.h>

/* CONFIG */
#define I2C_DEV "/dev/i2c-4"
#define MPU_ADDR 0x68

#define SAMPLE_DELAY_MS 500
#define ALERT_TIME_MS 5000
#define TILT_THRESHOLD 7.0
#define AVG_SAMPLES 5

#define BOT_TOKEN "8561189280:AAHd7ruFtBHIs_lXcDhBh7Y30TmmxbFK_pI"
#define CHAT_ID "8106006550"

/* I2C READ */
int read_regs(int fd, uint8_t reg, uint8_t *buf, int len)
{
    if (write(fd, &reg, 1) != 1)
        return -1;
    return read(fd, buf, len);
}

/* Read tilt angle */
double read_tilt(int fd)
{
    uint8_t d[6];
    if (read_regs(fd, 0x3B, d, 6) != 6)
        return 999.0;

    int16_t ax = (d[0] << 8) | d[1];
    int16_t ay = (d[2] << 8) | d[3];
    int16_t az = (d[4] << 8) | d[5];

    double Ax = ax / 16384.0;
    double Ay = ay / 16384.0;
    double Az = az / 16384.0;

    return atan2(Ax, sqrt(Ay * Ay + Az * Az)) * 180.0 / M_PI;
}

/* Average tilt */
double read_tilt_avg(int fd)
{
    double sum = 0;
    int cnt = 0;

    for (int i = 0; i < AVG_SAMPLES; i++)
    {
        double v = read_tilt(fd);
        if (v != 999.0)
        {
            sum += v;
            cnt++;
        }
        usleep(2000);
    }

    return (cnt == 0) ? 999.0 : (sum / cnt);
}

/* Timestamp */
char *timestamp()
{
    static char buf[64];
    time_t now = time(NULL);
    struct tm *t = localtime(&now);
    strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", t);
    return buf;
}

/* Telegram alert */
void send_telegram_alert(double cur, double diff)
{
    char cmd[512];
    snprintf(cmd, sizeof(cmd),
             "/run/media/mmcblk0p6/naveen_antitheft/curl -k -s -X POST "
             "-d \"chat_id=%s\" "
             "-d \"text=🚨 BIKE THEFT ALERT! Current=%.2f°, Diff=%.2f°\" "
             "https://api.telegram.org/bot%s/sendMessage",
             CHAT_ID, cur, diff, BOT_TOKEN);

    system(cmd);
}

/* MAIN */
int main()
{
    int fd = open(I2C_DEV, O_RDWR);
    if (fd < 0)
    {
        perror("I2C open failed");
        return 1;
    }

    if (ioctl(fd, I2C_SLAVE, MPU_ADDR) < 0)
    {
        perror("I2C ioctl failed");
        return 1;
    }

    uint8_t wake[2] = {0x6B, 0x00};
    write(fd, wake, 2);
    usleep(100000);

    printf("🔒 Bike LOCKED\n");

    double baseline = read_tilt_avg(fd);
    if (baseline == 999.0)
    {
        printf("Baseline failed\n");
        return 1;
    }

    printf("Baseline = %.2f°\n", baseline);

    int tilt_timer = 0;

    while (1)
    {
        double cur = read_tilt_avg(fd);
        if (cur == 999.0)
            continue;

        double diff = fabs(cur - baseline);

       
	printf("[%s] Tilt=%.2f°, Diff=%.2f°, Timer=%d ms\n", timestamp(), cur, diff, tilt_timer);
        fflush(stdout);

        if (diff > TILT_THRESHOLD)
        {
            tilt_timer += SAMPLE_DELAY_MS;
            if (tilt_timer >= ALERT_TIME_MS)
            {
                printf("🚨 THEFT DETECTED\n");
                send_telegram_alert(cur, diff);
                tilt_timer = 0;
                sleep(5);
            }
        }
        else
        {
            tilt_timer = 0;
        }

        usleep(SAMPLE_DELAY_MS * 1000);
    }
}
