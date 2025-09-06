import { application } from "./application"

import ChatController from "./chat_controller"
application.register("chat", ChatController)

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import MenuController from "./menu_controller"
application.register("menu", MenuController)

import MessageController from "./message_controller"
application.register("message", MessageController)
