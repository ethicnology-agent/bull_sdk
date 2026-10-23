package com.bullbitcoin.onion;

import java.util.List;
import java.util.Map;

/** Hermetic JVM checks, run with javac --release 17 and java (no Android runtime). */
public final class SnowflakeEventBufferTest {
    @SuppressWarnings("unchecked")
    private static List<Map<String, Object>> events(Map<String, Object> snapshot) {
        return (List<Map<String, Object>>) snapshot.get("events");
    }

    private static void check(boolean condition) {
        if (!condition) throw new AssertionError();
    }

    public static void main(String[] args) throws InterruptedException {
        SnowflakeEventBuffer buffer = new SnowflakeEventBuffer();
        check(events(buffer.read(0)).isEmpty());
        long first = buffer.nextGeneration();
        long second = buffer.nextGeneration();
        check(first == 1 && second == 2);
        // A callback from an old controller must keep its original generation.
        buffer.record(second, 0, "starting", false);
        buffer.record(first, 100, "connectionStopped", true);
        check(events(buffer.read(0)).get(1).get("generation").equals(first));
        Map<String, Object> snapshot = buffer.read(0);
        events(snapshot).get(0).put("kind", "changed by reader");
        check(events(buffer.read(0)).get(0).get("kind").equals("starting"));
        check(events(buffer.read(1)).size() == 1);
        check(events(buffer.read(0)).size() == 2);
        for (int i = 0; i < 70; i++) buffer.record(second, i, "connected", false);
        snapshot = buffer.read(0);
        check(events(snapshot).size() == 64);
        check(snapshot.get("latestSequence").equals(72L));
        check(snapshot.get("dropped").equals(8L));
        check(buffer.read(8).get("dropped").equals(0L));
        check(events(buffer.read(72)).isEmpty());
        for (long invalid : new long[]{-1, 73}) {
            try { buffer.read(invalid); throw new AssertionError(); }
            catch (IllegalArgumentException expected) { /* fixed rejection */ }
        }
        Thread[] writers = new Thread[4];
        for (int i = 0; i < writers.length; i++) {
            writers[i] = new Thread(() -> {
                for (int j = 0; j < 1000; j++) buffer.record(second, j, "connected", false);
            });
            writers[i].start();
        }
        for (Thread writer : writers) writer.join();
        snapshot = buffer.read(0);
        check(snapshot.get("latestSequence").equals(4072L));
        long expected = 4009;
        for (Map<String, Object> event : events(snapshot)) check(event.get("sequence").equals(expected++));
        System.out.println("SnowflakeEventBuffer checks passed");
    }
}
