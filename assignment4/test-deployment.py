#!/usr/bin/env python3
# Install requirement with: pip install requests
import requests

FRONTEND_HEADER_NAME = "CC-Frontend-Server"
BACKEND_HEADER_NAME = "CC-Backend-Server"
NUM_REQUESTS = 100
NUM_FRONTEND_CONTAINERS = 4
NUM_BACKEND_CONTAINERS = 6

class DeploymentTester(object):

	def __init__(self):
		self.backend_containers = set()
		self.frontend_containers = set()
		self.replies = set()

	def run_all_requests(self, target):
		print("Sending %s requests to %s..." % (NUM_REQUESTS, target))
		for _ in range(NUM_REQUESTS):
			self.run_request(target)

	def run_request(self, target):
		response = requests.get("http://%s" % target)
		frontend = self.extract_header(response, FRONTEND_HEADER_NAME)
		backend = self.extract_header(response, BACKEND_HEADER_NAME)
		self.frontend_containers.add(frontend.strip())
		self.backend_containers.add(backend.strip())
		self.replies.add(response.text.strip())

	def extract_header(self, response, header_name):
		if header_name not in response.headers:
			raise Exception("Missing header %s in response. Received headers: %s" % (header_name, list(response.headers.keys())))
		return response.headers[header_name]

	def check_set_len(self, the_set, set_name, expected_len):
		for l in expected_len:
			if len(the_set) == l:
				return 0
		print("Test failure: Unexpected number of encountered %s: Expected %s, have %s" % (set_name, expected_len, len(the_set)))
		return 1

	def validate(self):
		print("")
		print("Encountered %s frontends:" % (len(self.frontend_containers)))
		for front in self.frontend_containers:
			print(front)
		print("")
		print("Encountered %s backends:" % (len(self.backend_containers)))
		for back in self.backend_containers:
			print(back)
		print("")
		replies = list(self.replies)
		replies.sort()
		print("Encountered %s reply texts:" % (len(replies)))
		for reply in replies:
			print(reply)
		print("")
		
		result = 0
		result += self.check_set_len(self.backend_containers, "backend containers", [NUM_BACKEND_CONTAINERS])
		result += self.check_set_len(self.frontend_containers, "frontend containers", [NUM_FRONTEND_CONTAINERS])
		expected_replies = NUM_FRONTEND_CONTAINERS * NUM_BACKEND_CONTAINERS
		result += self.check_set_len(self.replies, "replies", [expected_replies, int(expected_replies/2), int(expected_replies*3/4)])
		if result == 0:
			print("All tests passed.")
		return result

def main(args):
	if len(args) != 3:
		print("Need 3 parameters: The reachable host:port pairs of the 3 Kubernetes worker nodes")
		return 1
	tester = DeploymentTester()
	for ip in args:
		tester.run_all_requests(ip)
	return tester.validate()

if __name__ == "__main__":
	import sys, os
	sys.exit(main(sys.argv[1:]))
