package swift

import (
	"fmt"
	"github.com/crhym3/go-endpoints/endpoints"
	"github.com/mjibson/goon"
	"net/http"
	"time"
)

const (
	clientId                    = "ClientId"
	IOS_CLIENT_ID               = "IOS_CLIENT_ID"
)

var (
	Scopes    = []string{endpoints.EmailScope}
	ClientIds = []string{clientId, endpoints.ApiExplorerClientId, IOS_CLIENT_ID}
	Audiences = []string{clientId, IOS_CLIENT_ID}
)

type SwiftSampleApi struct {
}

type GetReq struct {
}

type GetRes struct {
	Message string `json:"message"`
}

func (t *SwiftSampleApi) GetMessage(r *http.Request, _ *GetReq, res *GetRes) error {

	c := endpoints.NewContext(r)

	if u, error := endpoints.CurrentUser(c, Scopes, Audiences, ClientIds); error != nil {
		res.Message = "Hello World!"
		return nil
	} else {
		res.Message = fmt.Sprintf("Hello %s", u.Email)
		return nil
	}
}

type PostReq struct {
	_kind        string    `datastore "-" goon:"kind,Message"`
	Id           int64     `json:"-" datastore:"-" goon:"id"`
	Message      string    `json:"message" datastore:"message,noindex" endpoints:"required,req"`
	RegisteredAt time.Time `json:"-" datastore:"registeredAt"`
	Email        string    `json:"-" datastore:"email"`
}

type PostRes struct {
	Id           int64     `json:"id"`
	Message      string    `json:"message"`
	RegisteredAt time.Time `json:"registeredAt"`
	Email        string    `json:"email"`
}

func (t *SwiftSampleApi) PostMessage(r *http.Request, req *PostReq, res *PostRes) error {

	c := endpoints.NewContext(r)

	if u, error := endpoints.CurrentUser(c, Scopes, Audiences, ClientIds); error != nil {
		return endpoints.NewUnauthorizedError("Need auth")
	} else {
		req.Email = u.Email
	}

	req.RegisteredAt = time.Now()

	g := goon.NewGoon(r)

	if _, error := g.Put(req); error != nil {
		return error
	}

	res.Email = req.Email
	res.Message = req.Message
	res.Id = req.Id
	res.RegisteredAt = req.RegisteredAt

	return nil
}

func init() {
	api, err := endpoints.RegisterService(&SwiftSampleApi{}, "swiftsampleapi", "v1", "Swift Sample API", true)

	if err != nil {
		panic(err.Error())
	}

	info := api.MethodByName("GetMessage").Info()
	info.Name, info.HttpMethod, info.Path, info.Desc = "message.get", "GET", "message", "Get greeting"

	info = api.MethodByName("PostMessage").Info()

	info.Name, info.HttpMethod, info.Path, info.Desc = "message.post", "POST", "message", "Post greeting"
	info.Scopes, info.Audiences, info.ClientIds = Scopes, Audiences, ClientIds

	endpoints.HandleHttp()
}
