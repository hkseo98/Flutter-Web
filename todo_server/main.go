package main

import (
	"fmt"
	"net/http"

	"github.com/gorilla/pat"
	"github.com/unrolled/render"
	"github.com/urfave/negroni"
)

var rd *render.Render

var todoMap map[int]*Todo

var i = 0

// Todo struct
type Todo struct {
	Name           string `json:"name"`
	Completed      bool   `json:"completed"`
	RegisteredTime string `json:"registerd_time"`
	DueDate        string `json:"due_date"`
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	cors(w)
	fmt.Fprint(w, "Hello World")
}

func cors(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
}

func postTodoHandler(w http.ResponseWriter, r *http.Request) {
	cors(w)
	name := r.FormValue("name")
	registerdTime := r.FormValue("registered_time")
	dueDate := r.FormValue("due_date")
	todo := &Todo{name, false, registerdTime, dueDate}
	i = len(todoMap)
	todoMap[i] = todo
	rd.JSON(w, http.StatusOK, todoMap[i])
	i++
}

func fetchTodoList(w http.ResponseWriter, r *http.Request) {
	cors(w)
	rd.JSON(w, http.StatusOK, todoMap)
}

func deleteTodo(w http.ResponseWriter, r *http.Request) {
	cors(w)
	data := r.FormValue("registered_time")
	for key, element := range todoMap {
		if element.RegisteredTime == data {
			delete(todoMap, key)
			fmt.Fprintf(w, element.Name)
		}
	}
}

func main() {
	todoMap = make(map[int]*Todo)
	todoMap[0] = &Todo{"hi", false, "2021-0707 01:16:57.271", "null"}
	todoMap[1] = &Todo{"hello", false, "2021-0707 01:16:57.231", "null"}
	rd = render.New()
	mux := pat.New()
	mux.HandleFunc("/", indexHandler)
	mux.Post("/post_todo", postTodoHandler)
	mux.Get("/fetch_todo_list", fetchTodoList)
	mux.Post("/delete_todo", deleteTodo)
	n := negroni.Classic()
	n.UseHandler(mux)
	http.ListenAndServe(":3000", n)
}
