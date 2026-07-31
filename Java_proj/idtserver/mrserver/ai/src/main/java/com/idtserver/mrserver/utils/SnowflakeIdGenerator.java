package com.idtserver.mrserver.utils;

public class SnowflakeIdGenerator {

    // 初始时间戳 (纪元开始时间，可以自定义)
    private static final long EPOCH = 1609459200000L; // 2021-01-01 00:00:00 UTC

    // 每一部分的位数
    private static final long WORKER_ID_BITS = 5L; // 机器 ID
    private static final long DATACENTER_ID_BITS = 5L; // 数据中心 ID
    private static final long SEQUENCE_BITS = 12L; // 序列号

    // 每部分的最大值
    private static final long MAX_WORKER_ID = ~(-1L << WORKER_ID_BITS); // 最大值 31
    private static final long MAX_DATACENTER_ID = ~(-1L << DATACENTER_ID_BITS); // 最大值 31

    // 左移位数
    private static final long WORKER_ID_SHIFT = SEQUENCE_BITS;
    private static final long DATACENTER_ID_SHIFT = SEQUENCE_BITS + WORKER_ID_BITS;
    private static final long TIMESTAMP_LEFT_SHIFT = SEQUENCE_BITS + WORKER_ID_BITS + DATACENTER_ID_BITS;

    // 序列号掩码
    private static final long SEQUENCE_MASK = ~(-1L << SEQUENCE_BITS); // 最大值 4095

    private long workerId; // 机器 ID
    private long datacenterId; // 数据中心 ID
    private long sequence = 0L; // 当前毫秒内的序列号
    private long lastTimestamp = -1L; // 上次生成 ID 的时间戳

    public SnowflakeIdGenerator(long workerId, long datacenterId) {
        if (workerId > MAX_WORKER_ID || workerId < 0) {
            throw new IllegalArgumentException(String.format("Worker ID can't be greater than %d or less than 0", MAX_WORKER_ID));
        }
        if (datacenterId > MAX_DATACENTER_ID || datacenterId < 0) {
            throw new IllegalArgumentException(String.format("Datacenter ID can't be greater than %d or less than 0", MAX_DATACENTER_ID));
        }
        this.workerId = workerId;
        this.datacenterId = datacenterId;
    }

    // 生成唯一 ID 的方法
    public synchronized long nextId() {
        long timestamp = currentTimeMillis();

        // 如果当前时间小于上次时间戳，说明系统时钟回退，抛出异常
        if (timestamp < lastTimestamp) {
            throw new RuntimeException("Clock moved backwards. Refusing to generate id.");
        }

        // 如果在同一毫秒内生成 ID
        if (timestamp == lastTimestamp) {
            sequence = (sequence + 1) & SEQUENCE_MASK;
            // 如果序列号溢出（超过 4095），等待下一毫秒
            if (sequence == 0) {
                timestamp = waitUntilNextMillis(lastTimestamp);
            }
        } else {
            // 如果是新的毫秒，重置序列号
            sequence = 0L;
        }

        // 更新最后生成 ID 的时间戳
        lastTimestamp = timestamp;

        // 生成 ID，并返回
        return ((timestamp - EPOCH) << TIMESTAMP_LEFT_SHIFT) |
                (datacenterId << DATACENTER_ID_SHIFT) |
                (workerId << WORKER_ID_SHIFT) |
                sequence;
    }

    // 等待下一毫秒
    private long waitUntilNextMillis(long lastTimestamp) {
        long timestamp = currentTimeMillis();
        while (timestamp <= lastTimestamp) {
            timestamp = currentTimeMillis();
        }
        return timestamp;
    }

    // 获取当前时间的毫秒数
    private long currentTimeMillis() {
        return System.currentTimeMillis();
    }


}

