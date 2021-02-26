using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class OrbitPointScript : MonoBehaviour
{

    public float timer = 1f;
    float reTimer;
    public float horiRange = 3f;
    public float vertRange = 3f;
    public Transform subPoint;
    // Start is called before the first frame update
    void Start()
    {
        reTimer = timer;
    }

    // Update is called once per frame
    void Update()
    {
        if(timer > 0)
        {
            timer -= Time.deltaTime;
        }
        else
        {
            timer = reTimer;
            subPoint.transform.position = new Vector3(Random.Range(-1 * horiRange, horiRange), Random.Range(-1 * vertRange, vertRange));
        }
    }
}
