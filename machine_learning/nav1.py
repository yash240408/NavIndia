from flask import Flask, request, jsonify

app = Flask(__name__)

road_network = {
    'A': {'B': {'length': 5, 'potholes': 2, 'quality_index': 5, 'traffic_lights': 1}},
    'B': {'A': {'length': 5, 'potholes': 2, 'quality_index': 5, 'traffic_lights': 1},
          'C': {'length': 8, 'potholes': 5, 'quality_index': 4, 'traffic_lights': 2}},
    'C': {'B': {'length': 8, 'potholes': 5, 'quality_index': 4, 'traffic_lights': 2},
          'D': {'length': 6, 'potholes': 1, 'quality_index': 3, 'traffic_lights': 0}},
    'D': {'C': {'length': 6, 'potholes': 1, 'quality_index': 3, 'traffic_lights': 0}}
}

def dijkstra(graph, start, end):
    distances = {node: float('inf') for node in graph}
    distances[start] = 0
    predecessors = {}
    priority_queue = [(0, start)]

    while priority_queue:
        current_distance, current_node = min(priority_queue)
        priority_queue.remove((current_distance, current_node))

        if current_node == end:
            break

        for neighbor, attributes in graph[current_node].items():
            distance = current_distance + calculate_score(attributes)
            if distance < distances[neighbor]:
                distances[neighbor] = distance
                predecessors[neighbor] = current_node
                priority_queue.append((distance, neighbor))

    if end not in predecessors:
        return None

    optimal_route = []
    current_node = end
    while current_node != start:
        optimal_route.append(current_node)
        current_node = predecessors[current_node]
    optimal_route.append(start)
    optimal_route.reverse()

    return optimal_route

def calculate_score(attributes):
    return attributes['potholes'] + (10 - attributes['quality_index']) + attributes['traffic_lights']

@app.route('/route', methods=['GET', 'POST'])
def get_route():
    if request.method == 'POST':
        data = request.json
        start = data['start']
        end = data['end']
    elif request.method == 'GET':
        start = request.args.get('start')
        end = request.args.get('end')

    optimal_route = dijkstra(road_network, start, end)
    if optimal_route:
        return jsonify(optimal_route)
    else:
        return jsonify({'error': 'No route found'}), 404

if __name__ == '__main__':
    app.run(debug=True)
