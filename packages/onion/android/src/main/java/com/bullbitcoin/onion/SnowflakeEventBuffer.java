package com.bullbitcoin.onion;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/** Process-wide bounded history; readers own cursors and never consume each other's events. */
final class SnowflakeEventBuffer {
    private static final int CAPACITY = 64;

    private final ArrayDeque<Map<String, Object>> events = new ArrayDeque<>();
    private long sequence;
    private long generation;

    synchronized long nextGeneration() {
        return ++generation;
    }

    synchronized void record(long generation, long elapsedMs, String kind, boolean hasError) {
        final Map<String, Object> event = new HashMap<>();
        event.put("sequence", ++sequence);
        event.put("generation", generation);
        event.put("elapsedMs", elapsedMs);
        event.put("kind", kind);
        event.put("hasError", hasError);
        if (events.size() == CAPACITY) events.removeFirst();
        events.addLast(event);
    }

    synchronized Map<String, Object> read(long afterSequence) {
        if (afterSequence < 0 || afterSequence > sequence) {
            throw new IllegalArgumentException("Invalid Snowflake event cursor");
        }
        final ArrayList<Map<String, Object>> batch = new ArrayList<>();
        for (Map<String, Object> event : events) {
            if ((Long) event.get("sequence") > afterSequence) batch.add(new HashMap<>(event));
        }
        final long oldest = sequence - events.size() + 1;
        final Map<String, Object> result = new HashMap<>();
        result.put("events", batch);
        result.put("latestSequence", sequence);
        result.put("dropped", Math.max(0, oldest - afterSequence - 1));
        return result;
    }
}
