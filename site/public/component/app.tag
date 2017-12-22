<app>
  <section class={ alert-area: true, visible: notify }>
    <div ref="alert" class="notification is-primary"></div>
  </section>

  <section class="hero is-fullheight">
    <div class="hero-head">
      <div class="container">
        <nav class="navbar">
          <div class="navbar-end" if={ opts.enable_login && !loggedin }>
            <a class="nav-item" onclick={ google_auth }>
              <span class="icon">
                <i class="fa fa-google"></i>
              </span>
            </a>
          </div>
          <div class="navbar-end" if={ opts.enable_login && loggedin }>
            <span class="nav-item">
              <span class="icon has-text-success">
                <i class="fa fa-google"></i>
              </span>
            </span>
          </div>
        </nav>
      </div>
    </div>
    <div class="hero-body">
      <div class="container has-text-centered">
        <div class="level-item center">
          <p class="control has-addons">
            <input class="input search" type="text" placeholder="" autocomplete="off" ref="query" onkeypress={ search_with_enter }>
            <button class={ is-loading: queuingNas || queuingDrive, button: true, is-info: true } onclick={ search }>
              検索
            </button>
          </p>
          <img src="/images/kensaku.png" width="50px" height="35px" />
        </div>
        <div>
       <div class="structure" if={ ready }>
         <div class="count">
            <h4 class="subtitle is-5 count-text" if={ !queuingNas }>{ "NAS : " + nas.length + "件ヒット" }</h4>
            <h4 class="subtitle is-5 count-text" if={ opts.enable_login && loggedin && !queuingDrive }>{ "Google Drive : " + drive.length + "件ヒット" }</h4>
          </div>
          <div class="level" if={ ready }>
            <div class="level-item filter-wrap">
              <p class="control has-icons-right">
                <input type="text" ref="filterQuery" class="input filter" placeholder="絞り込み" required="" aria-required="true"  onkeydown={ filter }>
                  <span class="icon is-small is-right">
                    <i class="fa fa-filter"></i>
                  </span>
              </p>
              <p class="hitted">{ hitted + " / " + results.length  + " 抽出" }</p>
            </div>
          </div>
          <div>
            <div class="column" each={ result in showable }>

              <div class="box" if={ result.type == 'nas'}>
                <article class="media">
                  <div class="media-left">
                    <figure class="image is-64x64">
                      <img src="/images/folder.png" alt="nas">
                    </figure>
                  </div>
                  <div class="media-content">
                    <div class="content">
                      <p>
                        <a onclick={ copy_file }><strong>{ result.file }</strong></a>
                        <br>
                        <br>
                        <a onclick={ copy_folder }>{ "フォルダ - " + result.folder }</a>
                      </p>
                    </div>
                  </div>
                </article>
              </div>

              <div class="box" if={ result.type == 'drive'}>
                <article class="media">
                  <div class="media-left">
                    <figure class="image is-64x64">
                      <img src="/images/drive.png" alt="drive">
                    </figure>
                  </div>
                  <div class="media-content">
                    <div class="content">
                      <p>
                        <a href={ result.link } target="_blank"><strong>{ result.file }</strong></a>
                        <br>
                        <br>
                        <a onclick={ openParent } if={ result.parent }>フォルダを開く</a>
                      </p>
                    </div>
                  </div>
                </article>
              </div>
            </div>
            <h4 if={ hitted > limit }>{ "あと" + (hitted - limit) + "件あるよ" }</h4>
            <input ref="clip" class="clip" />
          </div>
        </div>
      </div>
    </div>
  </section>

  <footer class="footer">
    <div class="container">
      <div class="content has-text-centered">
        <p>
          Copyright (c) 2017 kentork
        </p>
      </div>
    </div>
  </footer>

  <style scoped>
    .alert-area {
      position: fixed;
      z-index: 1000;
      top: 0;
      bottom: 0;
      left: 0;
      right: 0;
      opacity: 0;
      visibility: collapse;
      transition: all 0.5s ease-out;
    }
    .alert-area.visible {
      opacity: 1;
      visibility: visible;
    }
    .alert-area > div {
      border-radius: 0;
      text-align: center;
    }

    .hero-head .nav {
      box-shadow: none;
    }
    .center {
      display: flex;
      justify-content: center;
    }
    .count {
      margin-bottom: 30px;
    }
    .count-text {
      color: #b1b5b9;
    }
    .clip {
      background: #f5f7fa;
      border: #f5f7fa;
      color: #f5f7fa;
      outline: none;
    }
    .clip::selection {
      background: #f5f7fa;
      border: #f5f7fa;
      color: #f5f7fa;
    }
    .hidden {
      visibility: hidden;
    }
    .hero-body .input.search {
      width: 460px;
    }
    .filter-wrap {
      margin-bottom: 32px;
    }
    .filter {
      width: 460px;
    }
    .hitted {
      line-height: 29px;
      margin-left: 14px;
      color: #8e8e8e;
    }
    .structure {
      background: #f5f7fa;
      border-radius: 4px;
      padding-top: 22px;
      padding-bottom: 22px;
      margin-top: 30px;
    }
    .column {
      padding: 4px 10px;
    }
    .result {
      background: white;
      border-radius: 3px;
      border: 1px solid #d3d6db;
      padding: 8px 15px;
      display:flex
    }
  </style>

  <script>
    this.nas = []
    this.drive = []

    this.results = []
    this.showable = []
    this.hitted = 0

    this.ready = false
    this.queuingNas = false
    this.queuingDrive = false

    this.limit = 100

    this.loggedin = this.opts.logged_in

    this.notify = false

    // alert
    showAlert(str) {
      this.refs.alert.innerHTML = str
      this.notify = true
      setTimeout(self => {self.notify = false; riot.update()}, 2000, this)
    }

    //  searching
    search_with_enter(e) {
      if (e.keyCode == 13) {
        this.search(e)
      }
      return true
    }
    search(e) {
      const queryString = this.refs.query.value.trim()

      if(queryString != "") {
        this.results = []
        this.showable = []
        this.hitted = 0

        // search in nas
        this.queuingNas = true
        this.searchInNas(queryString)

        // search in drive
        if (this.loggedin) {
          this.queuingDrive = true
          this.searchInGoogleDrive(queryString)
        }
      }
    }
    setResult() {
      this.results = this.nas.concat(this.drive).sort((a, b) => b.time - a.time)
      this.showable = this.results.slice(0, this.limit)
      this.hitted = this.results.length
    }


    // filtering
    filter(e) {
      if (e.keyCode != 229 || e.key == "Enter") {
        const self = this
        setTimeout( () => {
          const queryString = self.refs.filterQuery.value.split(' ')
          if (queryString.length == 0 && queryString[0] == "") {
            self.showable = self.results.slice(0, self.limit)
            self.hitted = self.results.length
          }else{
            const tmp = self.results.filter(p => queryString.every(q => self.querying(p,q)))
            self.showable = tmp.slice(0, self.limit)
            self.hitted = tmp.length
          }
          riot.update()
        }, 200)
      }
      return true
    }
    querying(target, query) {
      return ` ${query}`.indexOf(' -') == -1 ?
        target.body.indexOf(query) != -1 :
        query.length > 1 ? target.body.indexOf(query.slice(1)) == -1 : true
    }


    // Searching in NAS
    searchInNas(query) {
      this.nas = []
      fetch(`/api/search?query=${query}`)
        .then(response => response.text())
        .then(text => JSON.parse(text))
        .then(json => {
          this.nas = json.map(file => ({
            type: 'nas',
            body: file.path,   // search target
            path: file.path,
            file: file.path.split('\\').pop(),
            folder: file.path.split('\\').reverse().slice(1).reverse().join('\\'),
            time: new Date(file.date)
          }))
          this.queuingNas = false
          this.ready = true
          this.setResult()
          riot.update()
        })
    }
    copy_file(e) {
      this.refs.clip.value = e.item.result.path
      this.refs.clip.select()
      document.execCommand('copy')
      this.showAlert(`クリップボードにコピーしました - ' ${e.item.result.path} '`)
    }
    copy_folder(e) {
      this.refs.clip.value = e.item.result.folder
      this.refs.clip.select()
      document.execCommand('copy')
      this.showAlert(`クリップボードにコピーしました - ' ${e.item.result.folder} '`)
    }


    // Searching in Google Drive
    google_auth() {
      const self = this
      gapi.auth.authorize({
        'client_id': opts.client_id,
        'scope': opts.scope,
        'immediate': false
      }, function(authResult) {
        if (authResult && !authResult.error) {
          gapi.client.load('drive', 'v2')

          alert("ログインに成功しました")
          self.loggedin = true
        } else {
          alert("ログインに失敗しました")
        }
      });
    }
    searchInGoogleDrive(query) {
      this.drive = []
      this.queryGoogleDrives(query, result => {
        this.drive = result.map(file => ({
          type: 'drive',
          body: file.title,   // search target
          file: file.title,
          link: file.alternateLink,
          parent: file.parents.length > 0 ? file.parents[0].id : null,
          time: new Date(file.modifiedDate)
        }))
        this.queuingDrive = false
        this.ready = true
        this.setResult()
        riot.update()
      })
    }
    openParent(e) {
      if (e.item.result.parent) {
        gapi.client.drive.files.get({
          'fileId': e.item.result.parent
        }).execute(resp => {
          if (resp.alternateLink) {
            window.open(resp.alternateLink, '_blank')
          }
        })
      }
    }
    queryGoogleDrives(query, callback) {
      let getPageOfFiles = (request, result)  => {
        request.execute(resp => {
          result = result.concat(resp.items)
          if (resp.nextPageToken) {
            getPageOfFiles(
              gapi.client.drive.files.list({
                'pageToken': resp.nextPageToken,
                'q': `fullText contains '${query}'`
              }),
              result
            );
          } else {
            callback(result);
          }
        });
      };
      var initialRequest = gapi.client.drive.files.list({
        'q': `fullText contains '${query}'`
      });
      getPageOfFiles(initialRequest, []);
    }
  </script>
</app>
