---
title: "Laravel – Principi di progettazione e best practice"
slug: "laravel-principi-di-progettazione-e-best-practice"
description: ""
---

## ✏️ Contenuto

"### **Principio di singola responsabilità**

Una classe e un metodo dovrebbero avere una sola responsabilità.

Sbagliato:

```php
public function getFullNameAttribute(): string
{
    if (auth()->user() && auth()->user()->hasRole('client') && auth()->user()->isVerified()) {
        return 'Mr. ' . $this->first_name . ' ' . $this->middle_name . ' ' . $this->last_name;
    } else {
        return $this->first_name[0] . '. ' . $this->last_name;
    }
}
```

Giusto:

```php
public function getFullNameAttribute(): string
{
    return $this->isVerifiedClient() ? $this->getFullNameLong() : $this->getFullNameShort();
}

public function isVerifiedClient(): bool
{
    return auth()->user() && auth()->user()->hasRole('client') && auth()->user()->isVerified();
}

public function getFullNameLong(): string
{
    return 'Mr. ' . $this->first_name . ' ' . $this->middle_name . ' ' . $this->last_name;
}

public function getFullNameShort(): string
{
    return $this->first_name[0] . '. ' . $this->last_name;
}
```

### **Fat models, skinny controllers**

Inserisci tutta la logica legata al DB nei Model Eloquent oppure nei Repository a seconda che tu stia usando il Query Builder o le query SQL raw.

Sbagliato:

```php
public function index()
{
    $clients = Client::verified()
        ->with(['orders' => function ($q) {
            $q->where('created_at', '>', Carbon::today()->subWeek());
        }])
        ->get();

    return view('index', ['clients' => $clients]);
}
```

Giusto:

```php
public function index()
{
    return view('index', ['clients' => $this->client->getWithNewOrders()]);
}

class Client extends Model
{
    public function getWithNewOrders()
    {
        return $this->verified()
            ->with(['orders' => function ($q) {
                $q->where('created_at', '>', Carbon::today()->subWeek());
            }])
            ->get();
    }
}
```

### **Validazione**

Sposta le logiche di validazione dai controller alle Request class.

Sbagliato:

```php
public function store(Request $request)
{
    $request->validate([
        'title' => 'required|unique:posts|max:255',
        'body' => 'required',
        'publish_at' => 'nullable|date',
    ]);

    ...
}
```

Giusto:

```php
public function store(PostRequest $request)
{
    ...
}

class PostRequest extends Request
{
    public function rules()
    {
        return [
            'title' => 'required|unique:posts|max:255',
            'body' => 'required',
            'publish_at' => 'nullable|date',
        ];
    }
}
```

### **La logica di business dovrebbe essere nella classe di servizio**

Un controller deve avere una sola responsabilità, quindi sposta la logica di business dai controller alle classi di servizio.

Sbagliato:

```php
public function store(Request $request)
{
    if ($request->hasFile('image')) {
        $request->file('image')->move(public_path('images') . 'temp');
    }
    
    ...
}
```

Giusto:

```php
public function store(Request $request)
{
    $this->articleService->handleUploadedImage($request->file('image'));

    ...
}

class ArticleService
{
    public function handleUploadedImage($image)
    {
        if (!is_null($image)) {
            $image->move(public_path('images') . 'temp');
        }
    }
}
```

### **Non ripeterti (DRY: Don't Repeat Yourself)**

Riutilizzare il codice quando è possibile. Il Principio di Singola Responsabilità (SRP) ti aiuta a evitare la duplicazione. Inoltre, riutilizza i template blade, usa gli eloquenti scopes, ecc.

Sbagliato:

```php
public function getActive()
{
    return $this->where('verified', 1)->whereNotNull('deleted_at')->get();
}

public function getArticles()
{
    return $this->whereHas('user', function ($q) {
            $q->where('verified', 1)->whereNotNull('deleted_at');
        })->get();
}
```

Giusto:

```php
public function scopeActive($q)
{
    return $q->where('verified', 1)->whereNotNull('deleted_at');
}

public function getActive()
{
    return $this->active()->get();
}

public function getArticles()
{
    return $this->whereHas('user', function ($q) {
            $q->active();
        })->get();
}
```

### **Favorisci l'utilizzo dei Model Eloquent rispetto al Query Builder e alle query SQL raw. Preferisci le Collection agli array**

Eloquent ti consente di scrivere codice leggibile e manutenibile. Inoltre, Eloquent ha ottimi strumenti integrati come eliminazioni soft, eventi, scopes, ecc.

Sbagliato:

```sql
SELECT *
FROM `articles`
WHERE EXISTS (SELECT *
              FROM `users`
              WHERE `articles`.`user_id` = `users`.`id`
              AND EXISTS (SELECT *
                          FROM `profiles`
                          WHERE `profiles`.`user_id` = `users`.`id`) 
              AND `users`.`deleted_at` IS NULL)
AND `verified` = '1'
AND `active` = '1'
ORDER BY `created_at` DESC
```

Giusto:

```php
Article::has('user.profile')->verified()->latest()->get();
```

### **Assegnazione di massa**

Sbagliato:

```php
$article = new Article;
$article->title = $request->title;
$article->content = $request->content;
$article->verified = $request->verified;

// Add category to article
$article->category_id = $category->id;
$article->save();
```

Giusto:

```php
$category->article()->create($request->validated());
```

### **Non eseguire query nei template Blade e utilizzare l'eager loading (problema N + 1)**

Sbagliato (per 100 utenti, verranno eseguite 101 query DB):

```blade
@foreach (User::all() as $user)
    {{ $user->profile->name }}
@endforeach
```

Giusto (per 100 utenti, verranno eseguite 2 query DB):

```php
$users = User::with('profile')->get();

@foreach ($users as $user)
    {{ $user->profile->name }}
@endforeach
```

### **Commenta il tuo codice, ma cerca anche di rendere autoesplicativi i nomi di metodi e variabili**

Sbagliato:

```php
if (count((array) $builder->getQuery()->joins) > 0)
```

Meglio:

```php
// Determine if there are any joins.
if (count((array) $builder->getQuery()->joins) > 0)
```

Giusto:

```php
if ($this->hasJoins())
```

### **Non inserire JS e CSS nei templte Blade e non inserire HTML nelle classi PHP**

Sbagliato:

```javascript
let article = `{{ json_encode($article) }}`;
```

Meglio:

```php
<input id="article" type="hidden" value='@json($article)'>

Or

<button class="js-fav-article" data-article='@json($article)'>{{ $article->name }}<button>
```

In un file Javascript:

```javascript
let article = $('#article').val();
```

Il modo migliore è utilizzare il pacchetto PHP-JS specializzato per trasferire i dati.

### **Usa file di configurazione e lingua, costanti anziché testo nel codice**

Sbagliato:

```php
public function isNormal()
{
    return $article->type === 'normal';
}

return back()->with('message', 'Your article has been added!');
```

Giusto:

```php
public function isNormal()
{
    return $article->type === Article::TYPE_NORMAL;
}

return back()->with('message', __('app.article_added'));
```

### **Segui le naming convention di Laravel**

Seguire [Standard PSR](https://www.php-fig.org/psr/psr-12/).

Inoltre, segui le convenzioni di denominazione accettate dalla comunità Laravel:

Cosa | Come | Giusto | Sbagliato
------------ | ------------- | ------------- | -------------
Controller | singolare | ArticleController |~~ArticlesController~~
Route | plurale | articles/1 | ~~article/1~~
Route name | snake_case con notazione punto | users.show_active | ~~users.show-active, show-active-users~~
Model | singolare | User | ~~Users~~
Relazioni hasOne o belongsTo | singolare | articleComment |~~articleComments, article_comment~~
Tutte le altre relazioni | plurale | articleComments | ~~articleComment, article_comments~~
Tabella | plurale | article_comments | ~~article_comment, articleComments~~
Tabella pivot | nomi di modelli singolari in ordine alfabetico | article_user | ~~user_article, articles_users~~
Colonna della tabella | snake_case senza nome modello | meta_title |~~Meta Title; articolo meta_title~~
Proprietà del Model | snake_case | $ model->created_at |~~$model->createdAt~~
Foreign key | modello in singolare con un suffisso _id | article_id | ~~ArticleId, id_article, articles_id~~
Chiave primaria | - | id |~~custom_id~~
Migration | - | 2017_01_01_000000_create_articles_table |~~2017_01_01_000000_articles~~
Metodo | camelCase | getAll | ~~get_all~~
Metodo nel resource controller | [resource](https://laravel.com/docs/master/controllers#resource-controllers) | store | ~~saveArticle~~
Metodo nella test class | camelCase | testGuestCannotSeeArticle |~~test_guest_cannot_see_article~~
Variabile | camelCase | $articolesWithAuthor |~~$articles_with_author~~
Collection | descrittivo, plurale | $activeUsers = User::active()->get() | ~~$active, $data~~
Oggetto | descrittivo, singolare | $activeUser = User::active()->first() | ~~$users, $obj~~
Indice file di configurazione e lingua | snake_case | articles_enabled |~~ArticlesEnabled; articles-enabled~~
View | kebab-case | show-filtered.blade.php | ~~showFiltered.blade.php, show_filtered.blade.php~~
Config | snake_case | google_calendar.php |~~googleCalendar.php, google-calendar.php~~
Contratto (interfaccia) | aggettivo o sostantivo | AuthenticationInterface | ~~Authenticatable, IAuthentication~~
Trait | aggettivo | Notificabile | ~~NotificationTrait~~
Trait [(PSR)](https://www.php-fig.org/bylaws/psr-naming-conventions/) | adjective | NotifiableTrait | ~~Notification~~
Enum | singular | UserType | ~~UserTypes~~, ~~UserTypeEnum~~
FormRequest | singular | UpdateUserRequest | ~~UpdateUserFormRequest~~, ~~UserFormRequest~~, ~~UserRequest~~
Seeder | singular | UserSeeder | ~~UsersSeeder~~

### **Utilizzare una sintassi più breve e più leggibile ove possibile**

Sbagliato:

```php
$request->session()->get('cart');
$request->input('name');
```

Giusto:

```php
session('cart');
$request->name;
```

Più esempi:

Common syntax | Shorter and more readable syntax
------------ | -------------
`Session::get('cart')` | `session('cart')`
`$request->session()->get('cart')` | `session('cart')`
`Session::put('cart', $data)` | `session(['cart' => $data])`
`$request->input('name'), Request::get('name')` | `$request->name, request('name')`
`return Redirect::back()` | `return back()`
`is_null($object->relation) ? null : $object->relation->id` | `optional($object->relation)->id`
`return view('index')->with('title', $title)->with('client', $client)` | `return view('index', compact('title', 'client'))`
`$request->has('value') ? $request->value : 'default';` | `$request->get('value', 'default')`
`Carbon::now(), Carbon::today()` | `now(), today()`
`App::make('Class')` | `app('Class')`
`->where('column', '=', 1)` | `->where('column', 1)`
`->orderBy('created_at', 'desc')` | `->latest()`
`->orderBy('age', 'desc')` | `->latest('age')`
`->orderBy('created_at', 'asc')` | `->oldest()`
`->select('id', 'name')->get()` | `->get(['id', 'name'])`
`->first()->name` | `->value('name')`

### **Utilizzare il container IoC o i Facades invece di istanziare nuove classi**

La sintassi new Class crea un accoppiamento stretto tra le classi e complica i test. Utilizzare invece il container IoC o i Facades.

Sbagliato:

```php
$user = new User;
$user->create($request->validated());
```

Giusto:

```php
public function __construct(User $user)
{
    $this->user = $user;
}

...

$this->user->create($request->validated());
```

### **Non prelevare direttamente i dati dal file `.env`**

Passa i dati presenti nell'.env file ai file di configurazione e quindi usa l'helper `config ()` per prelevare i dati all'interno dell'applicazione.

Sbagliato:

```php
$apiKey = env('API_KEY');
```

Giusto:

```php
// config/api.php
'key' => env('API_KEY'),

// Use the data
$apiKey = config('api.key');
```

### **Memorizza le date nel formato standard. Utilizza gli accessors e i mutators per modificare il formato della data**

Sbagliato:

```php
{{ Carbon::createFromFormat('Y-d-m H-i', $object->ordered_at)->toDateString() }}
{{ Carbon::createFromFormat('Y-d-m H-i', $object->ordered_at)->format('m-d') }}
```

Giusto:

```php
// Model
protected $casts = [
    'ordered_at' => 'datetime',
];

public function getSomeDateAttribute($date)
{
    return $date->format('m-d');
}

// View
{{ $object->ordered_at->toDateString() }}
{{ $object->ordered_at->some_date }}
```

### **Altre buone pratiche**

Non inserire mai alcuna logica nei file di route.

Ridurre al minimo l'utilizzo di vanilla PHP nei template Blade. "
