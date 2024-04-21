from flask import Flask, jsonify
from threading import Thread
import time

app = Flask(__name__)

signals = ['red', 'green', 'yellow']
timer_intervals = {
    'position1': {

        'latitude': 26.76574685515445,
        'longitude': 75.8388288617248,
        'signal': {'red': 75, 'green': 25, 'yellow': 4}
    },
    'position2': {
        # signal 2
        'latitude': 26.768929548794457,
        'longitude': 75.84698090363155,
        'signal': {'red': 60, 'green': 30, 'yellow': 5}
    },
    'position3': {
        # signal 3
            'latitude': 26.77053657260424,
            'longitude': 75.85310081235693,
            'signal': {'red': 40, 'green': 20, 'yellow': 2}
    }
}

current_signal = 'red'
current_signal1 = 'red'
current_signal2 = 'red'
remaining_time = timer_intervals['position1']['signal'][current_signal]
remaining_time1 = timer_intervals['position2']['signal'][current_signal1]
remaining_time2 = timer_intervals['position3']['signal'][current_signal2]


def update_signal():
    global current_signal,current_signal1,current_signal2,remaining_time,remaining_time1,remaining_time2
    while True:
        remaining_time -= 1
        remaining_time1 -= 1
        remaining_time2 -= 1
        if remaining_time <= 0:
            current_signal = signals[(signals.index(current_signal) + 1) % len(signals)]
            remaining_time = timer_intervals['position1']['signal'][current_signal]
        if remaining_time1 <= 0:
            current_signal1 = signals[(signals.index(current_signal1) + 1) % len(signals)]
            remaining_time1 = timer_intervals['position2']['signal'][current_signal1]
        if remaining_time2 <= 0:
            current_signal2 = signals[(signals.index(current_signal2) + 1) % len(signals)]
            remaining_time2 = timer_intervals['position3']['signal'][current_signal2]
        time.sleep(1)


update_thread = Thread(target=update_signal)
update_thread.daemon = True
update_thread.start()


@app.route('/traffic-signal')
def traffic_signal():
    return jsonify({'position1':{'latitude': 26.76574685515445,'longitude': 75.8388288617248,'signal': current_signal,'remaining_time':remaining_time},
                    'position2':{ 'latitude': 26.768929548794457,'longitude': 75.84698090363155,'signal': current_signal1, 'remaining_time': remaining_time1},
                    'position3': {'latitude': 26.77053657260424,'longitude': 75.85310081235693,'signal': current_signal2, 'remaining_time': remaining_time2},
                    })


if __name__ == '__main__':
    app.run(debug=True)
